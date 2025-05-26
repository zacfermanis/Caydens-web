local Player = {
    x = 400,
    y = 500,
    width = 32,
    height = 32,
    speed = 200,
    jumpForce = -400,
    boostJumpForce = -600,  -- Stronger jump force when W is pressed
    isJumping = false,
    moveSpeed = {x = 0, y = 0},  -- Track movement speed in both directions
    -- Stamina properties
    maxStamina = 100,
    currentStamina = 100,
    staminaRegenRate = 20,  -- Stamina points per second
    staminaJumpCost = 30,   -- Stamina cost for normal jump
    staminaBoostCost = 50,  -- Stamina cost for boosted jump
    canJump = true,
    -- Ground detection
    isGrounded = false,
    groundCheckDistance = 5  -- Distance to check for ground
}

function Player:new()
    local player = {}
    setmetatable(player, self)
    self.__index = self
    
    -- Initialize physics body
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")
    player.shape = love.physics.newRectangleShape(player.width, player.height)
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setRestitution(0.2)
    player.fixture:setFriction(0.2)
    
    -- Initialize stamina
    player.currentStamina = self.maxStamina
    player.canJump = true
    
    return player
end

function Player:update(dt)
    -- Regenerate stamina
    if self.currentStamina < self.maxStamina then
        self.currentStamina = math.min(self.maxStamina, self.currentStamina + self.staminaRegenRate * dt)
    end
    
    -- Reset movement speed
    self.moveSpeed.x = 0
    self.moveSpeed.y = 0
    
    -- Handle movement (removed W from movement)
    if love.keyboard.isDown('s') then
        self.moveSpeed.y = self.speed
    end
    if love.keyboard.isDown('a') then
        self.moveSpeed.x = -self.speed
    end
    if love.keyboard.isDown('d') then
        self.moveSpeed.x = self.speed
    end
    
    -- Normalize diagonal movement
    if self.moveSpeed.x ~= 0 and self.moveSpeed.y ~= 0 then
        local length = math.sqrt(self.moveSpeed.x * self.moveSpeed.x + self.moveSpeed.y * self.moveSpeed.y)
        self.moveSpeed.x = (self.moveSpeed.x / length) * self.speed
        self.moveSpeed.y = (self.moveSpeed.y / length) * self.speed
    end
    
    -- Apply movement
    self.body:setLinearVelocity(self.moveSpeed.x, self.moveSpeed.y)
    
    -- Check if player is grounded
    local velocityY = self.body:getLinearVelocity()
    self.isGrounded = math.abs(velocityY) < 1  -- Consider grounded if vertical velocity is very small
    
    -- Reset jumping state when grounded
    if self.isGrounded then
        self.isJumping = false
    end
    
    -- Handle jumping with W boost and stamina
    if love.keyboard.isDown('space') and not self.isJumping and self.canJump then
        local jumpForce = self.jumpForce
        local staminaCost = self.staminaJumpCost
        
        if love.keyboard.isDown('w') then
            jumpForce = self.boostJumpForce
            staminaCost = self.staminaBoostCost
        end
        
        -- Check if we have enough stamina
        if self.currentStamina >= staminaCost then
            self.body:setLinearVelocity(self.body:getLinearVelocity(), jumpForce)
            self.isJumping = true
            self.currentStamina = self.currentStamina - staminaCost
        end
    end
    
    -- Update position
    self.x = self.body:getX()
    self.y = self.body:getY()
    
    -- Update jump state
    self.canJump = self.currentStamina >= self.staminaJumpCost
end

function Player:draw()
    -- Draw player
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height
    )
    
    -- Draw stamina bar
    local barWidth = 100
    local barHeight = 10
    local barX = 10
    local barY = 10
    
    -- Background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- Stamina fill
    local staminaRatio = self.currentStamina / self.maxStamina
    love.graphics.setColor(0, 1, 0, staminaRatio)  -- Green with opacity based on stamina
    love.graphics.rectangle("fill", barX, barY, barWidth * staminaRatio, barHeight)
    
    -- Border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    
    -- Stamina text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Stamina: " .. math.floor(self.currentStamina), barX, barY + barHeight + 5)
    
    -- Debug info
    love.graphics.print("Grounded: " .. tostring(self.isGrounded), 10, barY + barHeight + 25)
    love.graphics.print("Jumping: " .. tostring(self.isJumping), 10, barY + barHeight + 45)
end

return Player 