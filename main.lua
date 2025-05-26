-- Main entry point for the FPS game
local Engine = require("engine")

-- Game state
local game = {
    player = nil,
    running = true,
    mouseSensitivity = 0.1
}

-- Initialize the game
function love.load()
    -- Initialize the engine
    Engine.init()
    
    -- Create a player
    game.player = Player.new()
    game.player.position = Vector3.new(0, 1.7, 0)  -- Start at eye level
    game.player.mouseSensitivity = game.mouseSensitivity
    Engine.addPlayer(game.player)
    
    -- Set up input handling
    love.keyboard.setKeyRepeat(true)
    
    -- Set up camera
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)  -- Dark background
    
    -- Lock and hide the mouse
    love.mouse.setRelativeMode(true)
    love.mouse.setVisible(false)
end

-- Update game state
function love.update(dt)
    if not game.running then return end
    
    -- Handle player movement
    local moveDir = Vector3.new(0, 0, 0)
    
    if love.keyboard.isDown('w') then
        moveDir.z = 1   -- Backward (swapped from -1)
    elseif love.keyboard.isDown('s') then
        moveDir.z = -1  -- Forward (swapped from 1)
    end
    
    if love.keyboard.isDown('a') then
        moveDir.x = -1  -- Strafe left
    elseif love.keyboard.isDown('d') then
        moveDir.x = 1   -- Strafe right
    end
    
    -- Only move if there's actual input
    if moveDir.x ~= 0 or moveDir.z ~= 0 then
        game.player:move(moveDir, dt)
    end
    
    -- Update engine
    Engine.update(dt)
end

-- Handle mouse movement
function love.mousemoved(x, y, dx, dy)
    if game.player then
        game.player:rotate(dx, dy)
    end
end

-- Handle key presses
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- Handle window focus
function love.focus(f)
    if f then
        love.mouse.setRelativeMode(true)
        love.mouse.setVisible(false)
    end
end

-- Render the game
function love.draw()
    -- Draw the grid floor
    Engine.drawFloor()
    
    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Player Position: " .. 
        string.format("(%.2f, %.2f, %.2f)", 
            game.player.position.x,
            game.player.position.y,
            game.player.position.z
        ), 10, 10)
    
    love.graphics.print("Player Rotation: " .. 
        string.format("(%.2f, %.2f)", 
            game.player.yaw,
            game.player.pitch
        ), 10, 30)
    
    -- Draw crosshair at the center of the screen
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    love.graphics.setColor(1, 1, 1, 0.8)  -- Slightly transparent white
    love.graphics.circle("fill", centerX, centerY, 3)  -- Larger dot
    love.graphics.setColor(0, 0, 0, 0.8)  -- Black outline
    love.graphics.circle("line", centerX, centerY, 3)
end 