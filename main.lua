-- Game state
local gameState = {
    gravity = 1481,  -- Increased from 981 (+500)
    platforms = {},
    obstacles = {},
    hasWon = false,
    winMessage = "",
    winMessageTimer = 0,
    obstacleSpawnTimer = 0,
    obstacleSpawnInterval = 0.5,  -- Spawn obstacles every 0.5 seconds
    maxObstacles = 20,  -- Maximum number of obstacles allowed at once
    currentLevel = 1,  -- Track current level
    maxLevel = 10,     -- Maximum level
    playerHealth = 100,  -- Add player health
    maxHealth = 100,     -- Maximum health
    damageAmount = 20,    -- Damage per obstacle hit
    currentScreen = 1,    -- Track current screen
    totalScreens = 10,    -- Total number of screens to win
    screenHeight = 600,   -- Height of each screen
    cameraY = 0,          -- Camera Y position for scrolling
    deathScreenTimer = 0, -- Timer for death screen
    deathScreenDuration = 2,  -- Duration to show death screen (in seconds)
    hasRestarted = false  -- Track if we've already restarted
}

-- Initialize game
function love.load()
    -- Set up physics world
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, gameState.gravity)
    
    -- Load components
    Player = require('src.components.player')
    Platform = require('src.components.platform')
    WinZone = require('src.components.winZone')
    Obstacle = require('src.components.obstacle')
    
    -- Create player
    gameState.player = Player:new(gameState)
    
    -- Create platforms and win zone
    createLevel()
end

function createLevel()
    -- Clear existing platforms and obstacles
    gameState.platforms = {}
    for _, obstacle in ipairs(gameState.obstacles) do
        obstacle:destroy()
    end
    gameState.obstacles = {}
    
    -- Reset player health to full
    gameState.playerHealth = gameState.maxHealth
    
    -- Reset death screen timer and restart flag
    gameState.deathScreenTimer = 0
    gameState.hasRestarted = false
    
    -- Calculate level-specific parameters
    local level = gameState.currentLevel
    local platformCount = 30 + math.floor(level * 4)  -- More platforms for extended level
    local minPlatformWidth = math.max(40, 100 - (level * 5))
    local maxPlatformWidth = math.max(60, 150 - (level * 5))
    local levelWidth = love.graphics.getWidth()
    local levelHeight = love.graphics.getHeight()
    local totalLevelHeight = levelHeight * gameState.totalScreens  -- Total height for all screens
    
    -- Adjust obstacle spawn rate based on level
    gameState.obstacleSpawnInterval = math.max(0.2, 0.5 - (level * 0.03))
    gameState.maxObstacles = math.min(30, 20 + level)
    
    -- Create platforms
    local platformColors = {
        {0.7, 0.7, 0.7},  -- Gray
        {0.9, 0.9, 0.9}   -- White
    }
    
    -- Starting position at bottom of first screen (Level 1)
    local startX = levelWidth/2
    local startY = levelHeight - 100
    
    -- Create starting platform
    local startPlatform = Platform:new(startX, startY, 200, 30, {0.8, 0.8, 0.8})
    table.insert(gameState.platforms, startPlatform)
    
    -- Set player spawn position at the first platform
    gameState.player.respawnX = startX
    gameState.player.respawnY = startY - 50  -- Spawn slightly above the platform
    
    -- Reset player position to spawn point
    if gameState.player.body then
        gameState.player.body:setPosition(gameState.player.respawnX, gameState.player.respawnY)
        gameState.player.body:setLinearVelocity(0, 0)
    end
    
    -- Generate platforms leading upward through all screens
    local currentX = startX
    local currentY = startY
    local minHeightGap = 150   -- Increased for longer jumps
    local maxHeightGap = 300   -- Increased for longer jumps
    local minPlatformGap = 150  -- Increased from 100
    local maxPlatformGap = 350  -- Increased from 250
    
    -- Create a diagonal pattern of platforms leading upward through all screens
    for i = 1, platformCount do
        -- Determine diagonal direction (alternate between left-up and right-up)
        local direction = i % 2 == 0 and 1 or -1
        
        -- Calculate diagonal movement
        local diagonalFactor = love.math.random(0.6, 1.0)  -- How diagonal the movement is
        local xOffset = love.math.random(minPlatformGap, maxPlatformGap) * direction * diagonalFactor
        local heightGap = love.math.random(minHeightGap, maxHeightGap)
        
        -- Apply diagonal movement
        currentX = currentX + xOffset
        currentY = currentY - heightGap
        
        -- Keep platforms within screen bounds horizontally with some margin
        if currentX < 150 then
            currentX = 150
        elseif currentX > levelWidth - 150 then
            currentX = levelWidth - 150
        end
        
        -- Create main platform
        local width = love.math.random(minPlatformWidth, maxPlatformWidth)
        local color = platformColors[love.math.random(1, 2)]
        table.insert(gameState.platforms, Platform:new(currentX, currentY, width, 20, color))
        
        -- Add connecting platforms for diagonal paths
        if i < platformCount then
            -- Calculate next platform's rough position
            local nextDirection = -direction
            local nextXOffset = love.math.random(minPlatformGap, maxPlatformGap) * nextDirection * diagonalFactor
            local nextHeightGap = love.math.random(minHeightGap, maxHeightGap)
            local nextX = currentX + nextXOffset
            local nextY = currentY - nextHeightGap
            
            -- Add a small connecting platform if the gap is too large
            if math.abs(nextX - currentX) > maxPlatformGap * 0.8 then
                local connectX = (currentX + nextX) / 2
                local connectY = (currentY + nextY) / 2
                if connectX > 100 and connectX < levelWidth - 100 then
                    table.insert(gameState.platforms, Platform:new(connectX, connectY, 80, 15, {0.8, 0.8, 0.8}))
                end
            end
        end
        
        -- Occasionally add a small platform for variety
        if love.math.random() < 0.3 then  -- 30% chance
            local smallX = currentX + love.math.random(-100, 100)
            local smallY = currentY - love.math.random(50, 150)
            if smallX > 100 and smallX < levelWidth - 100 then
                table.insert(gameState.platforms, Platform:new(smallX, smallY, 60, 15, {0.8, 0.8, 0.8}))
            end
        end
    end
    
    -- Add win zone at the top of level 10
    local winZoneY = (gameState.totalScreens - 1) * gameState.screenHeight + 50  -- Win zone at the top of level 10
    gameState.winZone = WinZone:new(levelWidth/2, winZoneY)
    
    -- Reset win state
    gameState.hasWon = false
    gameState.winMessage = ""
    gameState.winMessageTimer = 0
    gameState.obstacleSpawnTimer = 0
    gameState.currentScreen = 1
    gameState.cameraY = 0
    
    -- Reset player state
    gameState.player.isDead = false
    gameState.player.deathTimer = 0
    gameState.player.currentStamina = gameState.player.maxStamina
    gameState.player.isJumping = false
    gameState.player.isCharging = false
    gameState.player.chargeTime = 0
    gameState.player.chargeDelayTimer = 0
    gameState.player.currentJumpTime = 0
    gameState.player.spacePressed = false
    gameState.player.moveSpeed = {x = 0}
end

-- Update game state
function love.update(dt)
    -- Update physics world
    world:update(dt)
    
    -- Update player
    gameState.player:update(dt)
    
    -- Check for out of bounds (void)
    if gameState.player.y > love.graphics.getHeight() + 100 or 
       gameState.player.x < -100 or 
       gameState.player.x > love.graphics.getWidth() + 100 then
        gameState.player.isDead = true
        gameState.player.deathTimer = 0
        gameState.deathScreenTimer = 0
        gameState.hasRestarted = false
    end
    
    -- Handle death screen
    if gameState.player.isDead then
        gameState.deathScreenTimer = gameState.deathScreenTimer + dt
        if gameState.deathScreenTimer >= gameState.deathScreenDuration and not gameState.hasRestarted then
            -- Reset level when death screen timer expires, but only once
            gameState.hasRestarted = true
            -- Reset health to full before creating new level
            gameState.playerHealth = gameState.maxHealth
            -- Create new level and reset to spawn point
            createLevel()
            return
        end
    end
    
    -- Update camera position based on player's screen
    local playerScreen = math.floor(gameState.player.y / gameState.screenHeight) + 1
    if playerScreen ~= gameState.currentScreen then
        gameState.currentScreen = playerScreen
        gameState.cameraY = (gameState.currentScreen - 1) * gameState.screenHeight
    end
    
    -- Update obstacles and check for collisions
    for i = #gameState.obstacles, 1, -1 do
        local obstacle = gameState.obstacles[i]
        
        -- Skip if obstacle is nil or destroyed
        if not obstacle or not obstacle.body then
            table.remove(gameState.obstacles, i)
        else
            obstacle:update(dt)
            
            -- Check if obstacle is too far below the current screen
            local obstacleScreen = math.floor(obstacle.y / gameState.screenHeight) + 1
            if obstacleScreen > gameState.currentScreen + 1 then
                -- Remove obstacles that are too far below
                obstacle:destroy()
                table.remove(gameState.obstacles, i)
            else
                -- Check for collision with player
                if not gameState.player.isDead and obstacle:checkCollision(gameState.player) then
                    -- Apply damage to player
                    gameState.playerHealth = math.max(0, gameState.playerHealth - gameState.damageAmount)
                    
                    -- Check if player is dead
                    if gameState.playerHealth <= 0 then
                        gameState.player.isDead = true
                        gameState.player.deathTimer = 0
                        -- Reset health to full when player dies
                        gameState.playerHealth = gameState.maxHealth
                    end
                    
                    -- Remove the obstacle that hit the player
                    obstacle:destroy()
                    table.remove(gameState.obstacles, i)
                elseif not obstacle.isActive then
                    obstacle:destroy()
                    table.remove(gameState.obstacles, i)
                end
            end
        end
    end
    
    -- Spawn new obstacles
    gameState.obstacleSpawnTimer = gameState.obstacleSpawnTimer + dt
    if gameState.obstacleSpawnTimer >= gameState.obstacleSpawnInterval then
        gameState.obstacleSpawnTimer = 0
        spawnObstacle()
    end
    
    -- Update win zone
    if gameState.winZone then
        gameState.winZone:update(dt)
        
        -- Check for win condition
        if not gameState.hasWon and gameState.winZone:checkWin(gameState.player) then
            gameState.hasWon = true
            if gameState.currentLevel < gameState.maxLevel then
                gameState.currentLevel = gameState.currentLevel + 1
                gameState.winMessage = "Level " .. (gameState.currentLevel - 1) .. " Complete! Starting Level " .. gameState.currentLevel
            else
                gameState.winMessage = "You've completed all levels! Press R to play again"
            end
            gameState.winMessageTimer = 3  -- Show message for 3 seconds
        end
    end
    
    -- Update win message timer
    if gameState.winMessageTimer > 0 then
        gameState.winMessageTimer = gameState.winMessageTimer - dt
        if gameState.winMessageTimer <= 0 and gameState.hasWon then
            createLevel()  -- Create next level when message disappears
        end
    end
end

-- Draw game
function love.draw()
    -- Apply camera transform
    love.graphics.push()
    love.graphics.translate(0, -gameState.cameraY)
    
    -- Draw platforms
    for _, platform in ipairs(gameState.platforms) do
        platform:draw()
    end
    
    -- Draw obstacles
    for _, obstacle in ipairs(gameState.obstacles) do
        obstacle:draw()
    end
    
    -- Draw win zone
    if gameState.winZone then
        gameState.winZone:draw()
    end
    
    -- Draw player
    gameState.player:draw()
    
    -- Reset camera transform
    love.graphics.pop()
    
    -- Draw UI elements (not affected by camera)
    -- Draw health bar
    local barWidth = 100
    local barHeight = 10
    local barX = 10
    local barY = 30
    
    -- Health bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Health bar fill
    local healthRatio = gameState.playerHealth / gameState.maxHealth
    love.graphics.setColor(1, 0, 0, healthRatio)  -- Red with opacity based on health
    love.graphics.rectangle("fill", barX, barY, barWidth * healthRatio, barHeight)
    
    -- Health bar border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. math.floor(gameState.playerHealth), barX, barY + barHeight + 5)
    
    -- Draw level info
    local currentLevel = gameState.totalScreens - gameState.currentScreen + 1
    love.graphics.print("Level: " .. currentLevel, 10, 70)
    love.graphics.print("Screen: " .. currentLevel .. "/" .. gameState.totalScreens, 10, 90)
    
    -- Draw debug info
    love.graphics.print("X: " .. math.floor(gameState.player.x), 10, 110)
    love.graphics.print("Y: " .. math.floor(gameState.player.y), 10, 130)
    love.graphics.print("Velocity Y: " .. math.floor(gameState.player.body:getLinearVelocity()), 10, 150)
    
    -- Draw win message
    if gameState.winMessageTimer > 0 then
        love.graphics.setColor(0, 1, 0, gameState.winMessageTimer)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(gameState.winMessage)
        love.graphics.print(gameState.winMessage,
            love.graphics.getWidth()/2 - textWidth/2,
            love.graphics.getHeight()/2
        )
    end
    
    -- Draw death screen
    if gameState.player.isDead then
        -- Create a semi-transparent black overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw "YOU DIED" text
        love.graphics.setColor(1, 0, 0, 1)
        local font = love.graphics.getFont()
        local text = "YOU DIED"
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        
        -- Draw text with a pulsing effect
        local pulse = math.sin(love.timer.getTime() * 5) * 0.2 + 0.8
        love.graphics.setColor(1, 0, 0, pulse)
        love.graphics.print(text,
            love.graphics.getWidth()/2 - textWidth/2,
            love.graphics.getHeight()/2 - textHeight/2 - 50
        )
        
        -- Draw respawn button
        local respawnText = "Press SPACE to Respawn"
        local respawnWidth = font:getWidth(respawnText)
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.print(respawnText,
            love.graphics.getWidth()/2 - respawnWidth/2,
            love.graphics.getHeight()/2 + 20
        )
        
        -- Draw leave button
        local leaveText = "Press ESC to Leave Level"
        local leaveWidth = font:getWidth(leaveText)
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.print(leaveText,
            love.graphics.getWidth()/2 - leaveWidth/2,
            love.graphics.getHeight()/2 + 60
        )
    end
end

function spawnObstacle()
    -- Spawn 2-3 obstacles at once
    local numObstacles = love.math.random(2, 3)
    
    for i = 1, numObstacles do
        -- Only spawn if we haven't reached the maximum
        if #gameState.obstacles < gameState.maxObstacles then
            -- Spawn at the top of level 10 (which is at the bottom of the screen)
            local topScreenY = 0  -- Level 10 is at the bottom
            local x = love.math.random(50, love.graphics.getWidth() - 50)
            -- Spawn above the top screen with spacing between obstacles
            local y = topScreenY - 100 - (i * 50)
            
            -- Randomize size between 20 and 40
            local size = love.math.random(20, 40)
            
            -- Create obstacle
            local obstacle = Obstacle:new(x, y, size)
            
            -- Add initial velocity to make them fall
            obstacle.body:setLinearVelocity(0, 150)  -- Slightly faster initial velocity
            
            table.insert(gameState.obstacles, obstacle)
        end
    end
end

-- Handle key press
function love.keypressed(key)
    if key == 'escape' then
        if gameState.player.isDead then
            -- Reset level and start from level 1
            gameState.currentLevel = 1
            createLevel()
        else
            love.event.quit()
        end
    elseif key == 'r' then
        -- Reset level and start from level 1
        gameState.currentLevel = 1
        createLevel()
    elseif key == 'space' and gameState.player.isDead then
        -- Instant respawn without waiting for timer
        gameState.hasRestarted = true
        gameState.deathScreenTimer = 0  -- Reset death screen timer
        gameState.playerHealth = gameState.maxHealth  -- Reset health
        gameState.player:respawn()  -- Call player's respawn function
    end
end 