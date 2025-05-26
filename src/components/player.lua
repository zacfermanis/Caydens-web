local Player = {
    x = 400,
    y = 500,
    width = 32,
    height = 32,
    speed = 400,  -- Increased from 200 to 400 for faster horizontal movement
    airSpeed = 350,  -- Slightly reduced speed in air for better control
    jumpForce = -2100,  -- Reduced from -4200 for slower jump
    boostJumpForce = -2900,  -- Reduced from -5800 for slower jump
    maxChargeJumpForce = -4500,  -- Reduced from -9000 for slower jump
    jumpDuration = 0.5,  -- Duration of jump in seconds
    currentJumpTime = 0,  -- Current time in jump
    isJumping = false,
    moveSpeed = {x = 0},  -- Only track horizontal movement
    gravityMultiplier = 3,  -- Triple gravity effect on player
    -- Stamina properties
    maxStamina = 100,
    currentStamina = 100,
    staminaRegenRate = 20,  -- Stamina points per second
    staminaJumpCost = 15,   -- Reduced from 30
    staminaBoostCost = 25,  -- Reduced from 50
    canJump = true,
    -- Ground detection
    isGrounded = false,
    groundCheckDistance = 5,  -- Distance to check for ground
    -- Charge jump properties
    isCharging = false,
    chargeTime = 0,
    maxChargeTime = 2.0,  -- Increased charge time for more noticeable charging
    chargeJumpCost = 40,   -- Stamina cost for charged jump
    chargeDelay = 0.2,     -- Delay before charging starts
    chargeDelayTimer = 0,  -- Timer for charge delay
    spacePressed = false,  -- Track if space was just pressed
    -- Death and respawn properties
    isDead = false,
    respawnX = 400,
    respawnY = 500,
    deathTimer = 0,
    respawnDelay = 1.0  -- Time to wait before respawning
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
    
    -- Initialize stamina and charge
    player.currentStamina = self.maxStamina
    player.canJump = true
    player.chargeTime = 0
    player.isCharging = false
    player.chargeDelayTimer = 0
    player.spacePressed = false
    player.isDead = false
    player.deathTimer = 0
    
    return player
end

function Player:respawn()
    self.isDead = false
    self.deathTimer = 0
    self.currentStamina = self.maxStamina
    self.body:setPosition(self.respawnX, self.respawnY)
    self.body:setLinearVelocity(0, 0)
    self.isJumping = false
    self.isCharging = false
    self.chargeTime = 0
    self.chargeDelayTimer = 0
    self.currentJumpTime = 0
    self.spacePressed = false
    self.moveSpeed = {x = 0}
end

function Player:update(dt)
    -- Handle death and respawn
    if self.isDead then
        self.deathTimer = self.deathTimer + dt
        if self.deathTimer >= self.respawnDelay then
            self:respawn()
        end
        return
    end
    
    -- Check for out of bounds
    if self.y > love.graphics.getHeight() + 100 or 
       self.x < -100 or 
       self.x > love.graphics.getWidth() + 100 then
        self.isDead = true
        self.deathTimer = 0
        return
    end
    
    -- Apply custom gravity to player
    local currentVelX, currentVelY = self.body:getLinearVelocity()
    self.body:setLinearVelocity(currentVelX, currentVelY + (world:getGravity() * self.gravityMultiplier * dt))
    
    -- Regenerate stamina
    if self.currentStamina < self.maxStamina then
        self.currentStamina = math.min(self.maxStamina, self.currentStamina + self.staminaRegenRate * dt)
    end
    
    -- Get current velocities
    local currentVelX, currentVelY = self.body:getLinearVelocity()
    
    -- Handle horizontal movement
    local targetSpeed = self.isGrounded and self.speed or self.airSpeed
    if love.keyboard.isDown('a') then
        currentVelX = -targetSpeed
    elseif love.keyboard.isDown('d') then
        currentVelX = targetSpeed
    else
        -- Apply slight air resistance when not pressing movement keys
        if not self.isGrounded then
            currentVelX = currentVelX * 0.95
        else
            currentVelX = 0
        end
    end
    
    -- Apply horizontal movement, preserve vertical velocity
    self.body:setLinearVelocity(currentVelX, currentVelY)
    
    -- Check if player is grounded
    local velocityY = self.body:getLinearVelocity()
    self.isGrounded = math.abs(velocityY) < 1
    
    -- Handle jump duration
    if self.isJumping then
        self.currentJumpTime = self.currentJumpTime + dt
        if self.currentJumpTime >= self.jumpDuration then
            self.isJumping = false
            self.currentJumpTime = 0
        end
    end
    
    -- Reset jumping state when grounded
    if self.isGrounded then
        self.isJumping = false
        self.currentJumpTime = 0
        if not love.keyboard.isDown('space') then
            self.isCharging = false
            self.chargeTime = 0
            self.chargeDelayTimer = 0
        end
    end
    
    -- Handle space key press for jumping
    if love.keyboard.isDown('space') and not self.spacePressed then
        self.spacePressed = true
        -- Quick tap jump
        if not self.isJumping and self.isGrounded and self.currentStamina >= self.staminaJumpCost then
            local jumpForce = self.jumpForce
            if love.keyboard.isDown('w') then
                jumpForce = self.boostJumpForce
                self.currentStamina = self.currentStamina - self.staminaBoostCost
            else
                self.currentStamina = self.currentStamina - self.staminaJumpCost
            end
            -- Preserve horizontal velocity when jumping
            local currentVelX = self.body:getLinearVelocity()
            self.body:setLinearVelocity(currentVelX, jumpForce)
            self.isJumping = true
            self.currentJumpTime = 0
        end
    elseif not love.keyboard.isDown('space') then
        self.spacePressed = false
    end
    
    -- Handle charging
    if love.keyboard.isDown('space') and not self.isJumping and self.isGrounded then
        if not self.isCharging then
            self.chargeDelayTimer = self.chargeDelayTimer + dt
            if self.chargeDelayTimer >= self.chargeDelay then
                self.isCharging = true
                self.chargeDelayTimer = 0
            end
        else
            self.chargeTime = math.min(self.chargeTime + dt, self.maxChargeTime)
        end
    end
    
    -- Handle jump release
    if self.isCharging and not love.keyboard.isDown('space') then
        local jumpForce = self.jumpForce
        local staminaCost = self.staminaJumpCost
        
        if love.keyboard.isDown('w') then
            jumpForce = self.boostJumpForce
            staminaCost = self.staminaBoostCost
        elseif self.chargeTime > 0 then
            -- Calculate charge jump force based on charge time with exponential scaling
            local chargeRatio = self.chargeTime / self.maxChargeTime
            chargeRatio = chargeRatio * chargeRatio  -- Square the ratio for exponential scaling
            jumpForce = self.jumpForce + (self.maxChargeJumpForce - self.jumpForce) * chargeRatio
            staminaCost = self.chargeJumpCost
        end
        
        -- Check if we have enough stamina
        if self.currentStamina >= staminaCost then
            -- Preserve horizontal velocity when jumping
            local currentVelX = self.body:getLinearVelocity()
            self.body:setLinearVelocity(currentVelX, jumpForce)
            self.isJumping = true
            self.currentJumpTime = 0
            self.currentStamina = self.currentStamina - staminaCost
        end
        
        self.isCharging = false
        self.chargeTime = 0
        self.chargeDelayTimer = 0
    end
    
    -- Update position
    self.x = self.body:getX()
    self.y = self.body:getY()
    
    -- Update jump state
    self.canJump = self.currentStamina >= self.staminaJumpCost
end

function Player:draw()
    -- Draw player
    if not self.isDead then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 
            self.x - self.width/2,
            self.y - self.height/2,
            self.width,
            self.height
        )
    end
    
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
    
    -- Draw charge bar near player
    if self.isCharging then
        local chargeBarWidth = 50
        local chargeBarHeight = 5
        local chargeBarX = self.x - chargeBarWidth/2
        local chargeBarY = self.y - self.height/2 - 15
        
        -- Background
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", chargeBarX, chargeBarY, chargeBarWidth, chargeBarHeight)
        
        -- Charge fill with pulsing effect
        local chargeRatio = self.chargeTime / self.maxChargeTime
        local pulse = math.sin(love.timer.getTime() * 10) * 0.1 + 0.9  -- Pulsing effect
        love.graphics.setColor(1, 0.5, 0, chargeRatio * pulse)  -- Orange with pulsing opacity
        love.graphics.rectangle("fill", chargeBarX, chargeBarY, chargeBarWidth * chargeRatio, chargeBarHeight)
        
        -- Border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", chargeBarX, chargeBarY, chargeBarWidth, chargeBarHeight)
    end
    
    -- Draw death message
    if self.isDead then
        love.graphics.setColor(1, 0, 0, 1 - (self.deathTimer / self.respawnDelay))
        local font = love.graphics.getFont()
        local text = "You Died!"
        local textWidth = font:getWidth(text)
        love.graphics.print(text,
            love.graphics.getWidth()/2 - textWidth/2,
            love.graphics.getHeight()/2
        )
    end
    
    -- Debug info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Grounded: " .. tostring(self.isGrounded), 10, barY + barHeight + 25)
    love.graphics.print("Jumping: " .. tostring(self.isJumping), 10, barY + barHeight + 45)
    love.graphics.print("Charging: " .. tostring(self.isCharging), 10, barY + barHeight + 65)
    love.graphics.print("Dead: " .. tostring(self.isDead), 10, barY + barHeight + 85)
end

return Player 