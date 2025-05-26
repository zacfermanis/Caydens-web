# System Patterns

## Architecture Overview
- Entity-Component System for game objects
- Physics-based movement system
- Stamina management system
- Platform generation system
- Win condition system

## Design Patterns
- Game Loop Pattern (LÖVE's update/draw cycle)
- Component Pattern for game entities
- State Pattern for player states
- Observer Pattern for collision events
- Factory Pattern for object creation

## Component Relationships
- Player Entity
  - Movement Component
  - Physics Component
  - Collision Component
  - Stamina Component
  - Ground Detection Component
- Platform Entity
  - Physics Component
  - Visual Component
- Win Zone Entity
  - Sensor Component
  - Visual Component
- Game State Manager
  - Menu State
  - Play State
  - Win State

## Critical Implementation Paths
1. Player Movement
   - Input handling
   - Physics application
   - Ground detection
   - Stamina management
   - Jump mechanics

2. Platform System
   - Platform generation
   - Physics setup
   - Visual rendering
   - Collision handling

3. Win Condition
   - Win zone placement
   - Collision detection
   - Win state management
   - Visual feedback

## Technical Decisions
- Using LÖVE's built-in physics engine
- Component-based architecture
- Stamina-based jump mechanics
- Ground detection for reliable jumping
- Space debris visual theme

## Notes
The game uses a component-based architecture with physics-based movement and a stamina system for jump mechanics. Ground detection ensures reliable jumping, and the win condition is implemented through a sensor-based win zone. 