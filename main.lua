-- Game state
local gameState = {
    gravity = 1500,
    platforms = {},
    hasWon = false,
    winMessage = "",
    winMessageTimer = 0
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
    
    -- Create player
    gameState.player = Player:new()
    
    -- Create platforms and win zone
    createLevel()
end

function createLevel()
    -- Clear existing platforms
    gameState.platforms = {}
    
    -- Create some random platforms
    local platformColors = {
        {0.7, 0.7, 0.7},  -- Gray
        {0.9, 0.9, 0.9}   -- White
    }
    
    -- Add some platforms at different heights
    for i = 1, 10 do
        local x = love.math.random(100, 700)
        local y = love.math.random(100, 500)
        local width = love.math.random(80, 150)
        local color = platformColors[love.math.random(1, 2)]
        
        table.insert(gameState.platforms, Platform:new(x, y, width, 20, color))
    end
    
    -- Add some larger platforms
    table.insert(gameState.platforms, Platform:new(400, 550, 200, 30, {0.8, 0.8, 0.8}))
    table.insert(gameState.platforms, Platform:new(200, 400, 250, 25, {0.9, 0.9, 0.9}))
    table.insert(gameState.platforms, Platform:new(600, 300, 180, 20, {0.7, 0.7, 0.7}))
    
    -- Add win zone at the top
    gameState.winZone = WinZone:new(400, 50)
    
    -- Reset win state
    gameState.hasWon = false
    gameState.winMessage = ""
    gameState.winMessageTimer = 0
end

-- Update game state
function love.update(dt)
    -- Update physics world
    world:update(dt)
    
    -- Update player
    gameState.player:update(dt)
    
    -- Update win zone
    if gameState.winZone then
        gameState.winZone:update(dt)
        
        -- Check for win condition
        if not gameState.hasWon and gameState.winZone:checkWin(gameState.player) then
            gameState.hasWon = true
            gameState.winMessage = "You Win! Press R to play again"
            gameState.winMessageTimer = 3  -- Show message for 3 seconds
        end
    end
    
    -- Update win message timer
    if gameState.winMessageTimer > 0 then
        gameState.winMessageTimer = gameState.winMessageTimer - dt
    end
end

-- Draw game
function love.draw()
    -- Draw platforms
    for _, platform in ipairs(gameState.platforms) do
        platform:draw()
    end
    
    -- Draw win zone
    if gameState.winZone then
        gameState.winZone:draw()
    end
    
    -- Draw player
    gameState.player:draw()
    
    -- Draw debug info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. math.floor(gameState.player.x), 10, 10)
    love.graphics.print("Y: " .. math.floor(gameState.player.y), 10, 30)
    love.graphics.print("Velocity Y: " .. math.floor(gameState.player.body:getLinearVelocity()), 10, 50)
    
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
end

-- Handle key press
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'r' then
        -- Reset level
        createLevel()
    end
end 