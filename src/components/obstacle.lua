local Obstacle = {}
Obstacle.__index = Obstacle

function Obstacle:new(x, y, size)
    local self = setmetatable({}, Obstacle)
    
    -- Create physics body
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newRectangleShape(size, size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setRestitution(0.2)  -- Bounce a little
    self.fixture:setFriction(0.3)
    
    -- Set properties
    self.size = size
    self.color = {0.8, 0.2, 0.2}  -- Red color for obstacles
    self.isActive = true
    self.x = x
    self.y = y
    
    -- Set collision category
    self.fixture:setCategory(3)  -- Category 3 for obstacles
    self.fixture:setMask(1, 2)   -- Collide with player (1) and platforms (2)
    
    return self
end

function Obstacle:update(dt)
    -- Update position from physics body
    if self.body and self.body:isDestroyed() == false then
        self.x, self.y = self.body:getPosition()
    end
    
    -- Check if obstacle is out of bounds
    if self.y > love.graphics.getHeight() + 100 then
        self.isActive = false
    end
end

function Obstacle:draw()
    if not self.isActive then return end
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x - self.size/2, self.y - self.size/2, self.size, self.size)
end

function Obstacle:destroy()
    if self.body and self.body:isDestroyed() == false then
        self.body:destroy()
    end
    self.isActive = false
end

function Obstacle:checkCollision(player)
    if not self.isActive then return false end
    
    -- Get obstacle position and size
    local ox = self.x
    local oy = self.y
    local osize = self.size
    
    -- Get player position and size
    local px = player.x
    local py = player.y
    local pwidth = player.width
    local pheight = player.height
    
    -- Check for collision using simple rectangle intersection
    return ox - osize/2 < px + pwidth/2 and
           ox + osize/2 > px - pwidth/2 and
           oy - osize/2 < py + pheight/2 and
           oy + osize/2 > py - pheight/2
end

return Obstacle 