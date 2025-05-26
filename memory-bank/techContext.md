# Technical Context

## Technology Stack
- LÖVE (Love2D) Framework
- Lua Programming Language
- Box2D Physics Engine (included with LÖVE)

## Development Setup
- LÖVE Framework installation
- Lua development environment
- Code editor with Lua support
- Version control system (Git)

## Dependencies
- LÖVE Framework
- Box2D Physics Engine
- Lua standard library

## Technical Constraints
- 2D graphics only
- Keyboard input only (WASD + spacebar)
- Single-threaded Lua execution
- LÖVE framework limitations
- Physics-based movement
- Stamina system limitations

## Tool Usage
- LÖVE for game engine and physics
- Lua for game logic and mechanics
- Box2D for collision detection
- Git for version control

## Implementation Details
1. Player Movement
   - A/D: Horizontal movement
   - S: Down movement
   - Spacebar: Jump
   - W + Spacebar: Boosted jump

2. Physics System
   - Box2D physics engine
   - Ground detection
   - Collision handling
   - Platform physics

3. Stamina System
   - Visual stamina bar
   - Stamina regeneration
   - Jump cost management
   - Boost jump mechanics

4. Win Condition
   - Sensor-based detection
   - Visual feedback
   - State management

## Notes
The game is built using LÖVE and Lua, with a focus on physics-based movement and stamina management. The implementation includes ground detection, platform generation, and a win condition system. 