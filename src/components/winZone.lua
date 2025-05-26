local WinZone = {
    width = 200,
    height = 50
}

function WinZone:new(x, y)
    local winZone = {}
    setmetatable(winZone, self)
    self.__index = self
    
    -- Set win zone properties
    winZone.x = x
    winZone.y = y
    winZone.width = self.width
    winZone.height = self.height
    winZone.active = true
    winZone.pulseTime = 0
    
    -- Create physics body (sensor)
    winZone.body = love.physics.newBody(world, winZone.x, winZone.y, "static")
    winZone.shape = love.physics.newRectangleShape(winZone.width, winZone.height)
    winZone.fixture = love.physics.newFixture(winZone.body, winZone.shape, 1)
    winZone.fixture:setSensor(true)  -- Make it a sensor so it doesn't collide physically
    
    return winZone
end

function WinZone:update(dt)
    -- Update pulse animation
    self.pulseTime = self.pulseTime + dt
end

function WinZone:draw()
    -- Draw win zone with pulsing effect
    local pulse = math.sin(self.pulseTime * 3) * 0.2 + 0.8
    love.graphics.setColor(0, 1, 0, 0.3 * pulse)  -- Green with pulsing opacity
    love.graphics.rectangle("fill", 
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height
    )
    
    -- Draw border
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.rectangle("line",
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height
    )
    
    -- Draw "WIN" text
    love.graphics.setColor(0, 1, 0, 0.8)
    local font = love.graphics.getFont()
    local text = "WIN"
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text,
        self.x - textWidth/2,
        self.y - textHeight/2
    )
end

function WinZone:checkWin(player)
    if not self.active then return false end
    
    -- Check if player is within win zone
    local playerX, playerY = player.x, player.y
    local playerWidth, playerHeight = player.width, player.height
    
    return playerX + playerWidth/2 > self.x - self.width/2 and
           playerX - playerWidth/2 < self.x + self.width/2 and
           playerY + playerHeight/2 > self.y - self.height/2 and
           playerY - playerHeight/2 < self.y + self.height/2
end

return WinZone 