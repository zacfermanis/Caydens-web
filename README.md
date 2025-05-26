# Lua FPS Game Engine

A simple but extensible First-Person Shooter game engine written in Lua, using the LÖVE framework.

## Features

- 3D vector mathematics
- Player movement and camera controls
- Basic shooting mechanics with ray casting
- Entity system
- Simple collision detection framework

## Requirements

- Lua 5.1 or later
- LÖVE framework (https://love2d.org/)

## Installation

1. Install LÖVE framework from https://love2d.org/
2. Clone this repository
3. Run the game using LÖVE:
   ```
   love .
   ```

## Controls

- W/A/S/D - Move player
- Mouse - Look around
- Left Click - Shoot
- ESC - Quit game

## Project Structure

- `engine.lua` - Core engine functionality
- `game.lua` - Example game implementation
- `README.md` - This file

## Extending the Engine

### Adding New Entities

```lua
local MyEntity = {
    position = Vector3.new(0, 0, 0),
    -- Add your properties here
}

function MyEntity.new()
    local e = {}
    setmetatable(e, { __index = MyEntity })
    return e
end

function MyEntity:update(dt)
    -- Add update logic here
end

-- Add to engine
local entity = MyEntity.new()
Engine.addEntity(entity)
```

### Adding New Weapons

```lua
local Weapon = {
    damage = 10,
    fireRate = 1.0,
    lastFireTime = 0
}

function Weapon:shoot(player)
    local ray = player:shoot()
    local hit = Engine.castRay(ray)
    if hit.hit then
        -- Handle hit
    end
end
```

## License

MIT License - Feel free to use and modify for your own projects.

## Contributing

Feel free to submit issues and pull requests to improve the engine. 