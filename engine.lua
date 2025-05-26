-- Basic FPS Game Engine
local Engine = {
    version = "1.0.0",
    entities = {},
    players = {},
    world = {
        floor = {
            size = 100,  -- Half-width of the floor
            gridSize = 10,  -- Size of each grid cell
            color = {0.2, 0.2, 0.2}  -- Dark gray color for grid
        }
    },
    running = false,
    camera = {
        fov = 70,  -- Field of view in degrees
        near = 0.1,
        far = 1000
    }
}

-- Vector3 class for 3D positions and directions
Vector3 = {
    x = 0,
    y = 0,
    z = 0
}

function Vector3.new(x, y, z)
    local v = {}
    setmetatable(v, { __index = Vector3 })
    v.x = x or 0
    v.y = y or 0
    v.z = z or 0
    return v
end

function Vector3:add(other)
    return Vector3.new(self.x + other.x, self.y + other.y, self.z + other.z)
end

function Vector3:sub(other)
    return Vector3.new(self.x - other.x, self.y - other.y, self.z - other.z)
end

function Vector3:mul(scalar)
    return Vector3.new(self.x * scalar, self.y * scalar, self.z * scalar)
end

-- Camera class for first-person view
Camera = {
    position = Vector3.new(0, 0, 0),
    yaw = 0,    -- Horizontal rotation
    pitch = 0,  -- Vertical rotation
    up = Vector3.new(0, 1, 0)  -- Always pointing up
}

function Camera.new()
    local c = {}
    setmetatable(c, { __index = Camera })
    return c
end

function Camera:update(position, yaw, pitch)
    self.position = position
    self.yaw = yaw
    self.pitch = pitch
end

function Camera:getViewMatrix()
    -- Calculate forward direction using both yaw and pitch
    local forward = Vector3.new(
        math.sin(math.rad(self.yaw)) * math.cos(math.rad(self.pitch)),
        -math.sin(math.rad(self.pitch)),
        math.cos(math.rad(self.yaw)) * math.cos(math.rad(self.pitch))
    )
    
    -- Calculate right vector (perpendicular to forward and up)
    local right = Vector3.new(
        math.sin(math.rad(self.yaw - 90)),
        0,
        math.cos(math.rad(self.yaw - 90))
    )
    
    -- Keep up vector constant
    local up = Vector3.new(0, 1, 0)
    
    -- Normalize vectors
    local length = math.sqrt(forward.x * forward.x + forward.y * forward.y + forward.z * forward.z)
    forward.x = forward.x / length
    forward.y = forward.y / length
    forward.z = forward.z / length
    
    length = math.sqrt(right.x * right.x + right.z * right.z)
    right.x = right.x / length
    right.z = right.z / length
    
    return {
        position = self.position,
        forward = forward,
        right = right,
        up = up
    }
end

-- Player class
Player = {
    position = Vector3.new(0, 1.7, 0),  -- Start at eye level
    yaw = 0,    -- Horizontal rotation
    pitch = 0,  -- Vertical rotation
    speed = 5.0,
    mouseSensitivity = 0.1,
    camera = nil
}

function Player.new()
    local p = {}
    setmetatable(p, { __index = Player })
    p.camera = Camera.new()
    return p
end

function Player:rotate(dx, dy)
    -- Horizontal rotation (left/right)
    self.yaw = self.yaw - dx * self.mouseSensitivity
    
    -- Vertical rotation (up/down)
    self.pitch = self.pitch - dy * self.mouseSensitivity  -- Negative dy to make mouse up = look up
    
    -- Clamp pitch to avoid flipping
    if self.pitch > 89 then self.pitch = 89 end
    if self.pitch < -89 then self.pitch = -89 end
    
    -- Keep yaw in a reasonable range
    if self.yaw > 360 then self.yaw = self.yaw - 360 end
    if self.yaw < 0 then self.yaw = self.yaw + 360 end
end

function Player:update(deltaTime)
    -- Update camera position to be at eye level
    self.camera:update(
        Vector3.new(self.position.x, self.position.y, self.position.z),
        self.yaw,
        self.pitch
    )
end

function Player:move(direction, deltaTime)
    local moveSpeed = self.speed * deltaTime
    
    -- Get camera view matrix for movement direction
    local view = self.camera:getViewMatrix()
    
    -- Calculate movement vector relative to camera direction
    -- Only use the horizontal components (x and z) for ground movement
    local moveX = direction.x * view.right.x + direction.z * view.forward.x
    local moveZ = direction.x * view.right.z + direction.z * view.forward.z
    
    -- Normalize the movement vector to prevent faster diagonal movement
    local length = math.sqrt(moveX * moveX + moveZ * moveZ)
    if length > 0 then
        moveX = moveX / length
        moveZ = moveZ / length
    end
    
    -- Update position (keep y constant for ground movement)
    self.position = Vector3.new(
        self.position.x + moveX * moveSpeed,
        self.position.y,  -- Keep y constant
        self.position.z + moveZ * moveSpeed
    )
end

-- Engine initialization
function Engine.init()
    print("FPS Game Engine " .. Engine.version .. " initialized")
    Engine.running = true
    Engine.entities = {}
end

-- Main game loop
function Engine.update(deltaTime)
    -- Update all entities
    for _, entity in pairs(Engine.entities) do
        if entity.update then
            entity:update(deltaTime)
        end
    end
    
    -- Update all players
    for _, player in pairs(Engine.players) do
        if player.update then
            player:update(deltaTime)
        end
    end
end

-- Add an entity to the engine
function Engine.addEntity(entity)
    table.insert(Engine.entities, entity)
end

-- Add a player to the engine
function Engine.addPlayer(player)
    table.insert(Engine.players, player)
end

-- Draw the grid floor
function Engine.drawFloor()
    -- Get camera view matrix
    local view = Engine.players[1].camera:getViewMatrix()
    
    -- Draw grid lines
    local size = Engine.world.floor.size
    local gridSize = Engine.world.floor.gridSize
    local color = Engine.world.floor.color
    
    -- Draw grid lines in X direction
    for z = -size, size, gridSize do
        local start = Engine.worldToScreen(Vector3.new(-size, 0, z), view)
        local finish = Engine.worldToScreen(Vector3.new(size, 0, z), view)
        
        if start and finish then
            love.graphics.setColor(color)
            love.graphics.line(start.x, start.y, finish.x, finish.y)
        end
    end
    
    -- Draw grid lines in Z direction
    for x = -size, size, gridSize do
        local start = Engine.worldToScreen(Vector3.new(x, 0, -size), view)
        local finish = Engine.worldToScreen(Vector3.new(x, 0, size), view)
        
        if start and finish then
            love.graphics.setColor(color)
            love.graphics.line(start.x, start.y, finish.x, finish.y)
        end
    end
end

-- Convert 3D point to 2D screen coordinates
function Engine.worldToScreen(point, view)
    -- Calculate point relative to camera
    local relative = Vector3.new(
        point.x - view.position.x,
        point.y - view.position.y,
        point.z - view.position.z
    )
    
    -- Project point onto camera plane
    local dot = relative.x * view.forward.x + 
                relative.y * view.forward.y + 
                relative.z * view.forward.z
    
    -- If point is behind camera, don't render it
    if dot <= 0 then
        return nil
    end
    
    -- Calculate screen coordinates with fixed perspective
    local scale = love.graphics.getWidth() / (2 * math.tan(math.rad(Engine.camera.fov / 2)))
    local screenX = (relative.x * view.right.x + 
                    relative.y * view.right.y + 
                    relative.z * view.right.z) * scale / dot + love.graphics.getWidth() / 2
    
    local screenY = -(relative.x * view.up.x + 
                     relative.y * view.up.y + 
                     relative.z * view.up.z) * scale / dot + love.graphics.getHeight() / 2
    
    return {x = screenX, y = screenY, depth = dot}
end

return Engine 