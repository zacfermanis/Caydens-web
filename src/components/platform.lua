local Platform = {
    width = 100,
    height = 20
}

function Platform:new(x, y, width, height, color)
    local platform = {}
    setmetatable(platform, self)
    self.__index = self
    
    -- Set platform properties
    platform.x = x
    platform.y = y
    platform.width = width or self.width
    platform.height = height or self.height
    platform.color = color or {0.7, 0.7, 0.7}  -- Default gray color
    
    -- Create physics body
    platform.body = love.physics.newBody(world, platform.x, platform.y, "static")
    platform.shape = love.physics.newRectangleShape(platform.width, platform.height)
    platform.fixture = love.physics.newFixture(platform.body, platform.shape, 1)
    platform.fixture:setFriction(0.3)
    
    return platform
end

function Platform:draw()
    -- Draw platform with a slight gradient effect
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", 
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height
    )
    
    -- Add a highlight effect
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill",
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height/4
    )
end

return Platform 