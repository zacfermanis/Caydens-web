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
    gameState.player = Player:new()
    
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
    local platformCount = 25 + math.floor(level * 3)  -- More platforms for extended level
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
    
    -- Starting position at bottom of first screen
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
    local minHeightGap = 100   -- Increased for longer jumps
    local maxHeightGap = 200   -- Increased for longer jumps
    local minPlatformGap = 50
    local maxPlatformGap = 150
    
    -- Create a zigzag pattern of platforms leading upward through all screens
    for i = 1, platformCount do
        -- Alternate between left and right movement
        local direction = i % 2 == 0 and 1 or -1
        local xOffset = love.math.random(minPlatformGap, maxPlatformGap) * direction
        currentX = currentX + xOffset
        
        -- Keep platforms within screen bounds horizontally
        if currentX < 100 then
            currentX = 100
        elseif currentX > levelWidth - 100 then
            currentX = levelWidth - 100
        end
        
        -- Move upward
        currentY = currentY - love.math.random(minHeightGap, maxHeightGap)
        
        -- Create platform
        local width = love.math.random(minPlatformWidth, maxPlatformWidth)
        local color = platformColors[love.math.random(1, 2)]
        table.insert(gameState.platforms, Platform:new(currentX, currentY, width, 20, color))
    end
    
    -- Add some strategic platforms for level progression
    if level <= 3 then
        -- Early levels: More forgiving platform placement
        table.insert(gameState.platforms, Platform:new(levelWidth/2, 200, 200, 30, {0.8, 0.8, 0.8}))
        table.insert(gameState.platforms, Platform:new(levelWidth/2, 100, 180, 25, {0.9, 0.9, 0.9}))
    else
        -- Later levels: More challenging platform placement
        table.insert(gameState.platforms, Platform:new(levelWidth/2, 200, 150, 25, {0.8, 0.8, 0.8}))
        table.insert(gameState.platforms, Platform:new(levelWidth/2, 100, 120, 20, {0.9, 0.9, 0.9}))
    end
    
    -- Add win zone at the top of the last screen
    local winZoneY = (gameState.totalScreens - 1) * gameState.screenHeight + 50  -- Win zone at the top of the last screen
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
    
    -- Handle death screen
    if gameState.player.isDead then
        gameState.deathScreenTimer = gameState.deathScreenTimer + dt
        if gameState.deathScreenTimer >= gameState.deathScreenDuration and not gameState.hasRestarted then
            -- Reset level when death screen timer expires, but only once
            gameState.hasRestarted = true
            -- Reset health to full before creating new level
            gameState.playerHealth = gameState.maxHealth
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
        obstacle:update(dt)
        
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
    love.graphics.print("Level: " .. gameState.currentLevel, 10, 70)
    love.graphics.print("Screen: " .. gameState.currentScreen .. "/" .. gameState.totalScreens, 10, 90)
    
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
            love.graphics.getHeight()/2 - textHeight/2
        )
        
        -- Draw restart message
        love.graphics.setColor(1, 1, 1, 0.8)
        local restartText = "Restarting level..."
        local restartWidth = font:getWidth(restartText)
        love.graphics.print(restartText,
            love.graphics.getWidth()/2 - restartWidth/2,
            love.graphics.getHeight()/2 + textHeight
        )
    end
end

function spawnObstacle()
    -- Spawn 2-3 obstacles at once
    local numObstacles = love.math.random(2, 3)
    
    for i = 1, numObstacles do
        -- Only spawn if we haven't reached the maximum
        if #gameState.obstacles < gameState.maxObstacles then
            local x = love.math.random(50, love.graphics.getWidth() - 50)
            local size = love.math.random(20, 40)
            -- Spawn obstacles above the screen
            table.insert(gameState.obstacles, Obstacle:new(x, -50 - (i * 30), size))
        end
    end
end

-- Handle key press
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'r' then
        -- Reset level and start from level 1
        gameState.currentLevel = 1
        createLevel()
    end
end 