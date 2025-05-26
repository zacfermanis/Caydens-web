# Technical Context

## Technologies Used
1. LÖVE2D Framework
   - Version: 11.4
   - Physics engine
   - Graphics system
   - Input handling
   - Audio system

2. Lua Programming Language
   - Version: 5.1
   - Object-oriented patterns
   - Component system
   - State management
   - Physics calculations

## Development Setup
1. Project Structure
   - src/
     - components/
       - player.lua
       - platform.lua
       - obstacle.lua
       - winZone.lua
     - main.lua
   - memory-bank/
     - Documentation files

2. Dependencies
   - LÖVE2D framework
   - No external libraries
   - Built-in physics engine
   - Standard Lua libraries

## Technical Constraints
1. Physics System
   - Custom gravity implementation
   - Collision detection
   - Momentum preservation
   - Ground detection

2. Performance Considerations
   - Obstacle management
   - Platform generation
   - Physics calculations
   - Memory usage

3. Platform Limitations
   - LÖVE2D physics engine
   - Lua performance
   - Memory management
   - Cross-platform compatibility

## Implementation Details
1. Movement System
   - Physics-based movement
   - Custom gravity multiplier
   - Air control mechanics
   - Ground detection

2. Health System
   - Health points tracking
   - Damage calculation
   - Visual health bar
   - Death handling

3. Level Generation
   - Procedural platform placement
   - Obstacle spawning
   - Win zone positioning
   - Difficulty scaling

4. Collision System
   - Physics-based collisions
   - Damage calculation
   - Win condition detection
   - Platform interaction

## Tool Usage
1. LÖVE2D
   - Physics engine
   - Graphics rendering
   - Input handling
   - Audio system

2. Development Tools
   - Text editor
   - Version control
   - Debug tools
   - Performance monitoring

## Code Patterns
1. Component System
   - Modular design
   - Reusable components
   - Clear interfaces
   - State management

2. Physics Implementation
   - Custom gravity
   - Collision handling
   - Movement calculations
   - State updates

3. Game Logic
   - Level progression
   - Health management
   - Win conditions
   - Difficulty scaling

## Notes
- Keep physics calculations efficient
- Maintain clean component interfaces
- Ensure proper memory management
- Follow LÖVE2D best practices 