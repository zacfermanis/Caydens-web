# System Patterns

## Architecture Overview
1. Component-Based Design
   - Player component
   - Platform component
   - Obstacle component
   - Win zone component
   - Health system
   - Screen management system

2. Physics System
   - LÖVE2D physics engine
   - Custom gravity implementation
   - Collision detection
   - Momentum preservation
   - Camera scrolling

3. State Management
   - Game state tracking
   - Level progression
   - Health management
   - Player state
   - Screen state
   - Death and respawn state

## Key Technical Decisions
1. Movement System
   - Independent horizontal/vertical controls
   - Physics-based movement
   - Air control mechanics
   - Momentum preservation
   - Ground detection
   - Stamina management

2. Health System
   - Simple health points
   - Visual health bar
   - Collision-based damage
   - Death and respawn mechanics
   - Health restoration
   - Single restart limit

3. Screen Management
   - 10-screen vertical progression
   - Camera scrolling
   - Screen transitions
   - Win zone placement
   - Screen counter
   - Fixed UI elements

4. UI System
   - Fixed stamina display
   - Dynamic charge indicator
   - Health bar with numerical value
   - Screen counter
   - Death screen overlay
   - Debug information

## Component Relationships
1. Player Interactions
   - Platform collision
   - Obstacle damage
   - Win zone detection
   - Health management
   - Screen transitions
   - Death handling

2. Level Structure
   - Platform generation
   - Obstacle spawning
   - Win zone placement
   - Player spawn point
   - Screen management
   - Camera control

3. Game Flow
   - Level progression
   - Health management
   - Death and respawn
   - Win condition
   - Screen transitions
   - UI updates

## Critical Implementation Paths
1. Movement
   - Horizontal movement (A/D)
   - Jumping (Space)
   - Boost jumps (W)
   - Air control
   - Stamina management
   - Charge jumps

2. Health
   - Health bar display
   - Damage calculation
   - Death handling
   - Respawn mechanics
   - Health restoration
   - Single restart limit

3. Screen Management
   - Camera scrolling
   - Screen transitions
   - UI positioning
   - Win zone placement
   - Platform generation
   - Obstacle management

## Design Patterns
1. Component Pattern
   - Modular game objects
   - Reusable components
   - Clear separation of concerns
   - UI management
   - Screen handling

2. State Pattern
   - Game state management
   - Player state handling
   - Level state tracking
   - Screen state
   - Death state
   - UI state

3. Observer Pattern
   - Collision detection
   - Health updates
   - Win condition checking
   - Screen transitions
   - Death handling
   - UI updates

## Technical Constraints
1. Physics
   - LÖVE2D physics limitations
   - Custom gravity implementation
   - Collision handling
   - Camera scrolling
   - Screen transitions

2. Performance
   - Obstacle management
   - Platform generation
   - Physics calculations
   - Screen transitions
   - UI updates

3. Gameplay
   - Movement responsiveness
   - Health balance
   - Difficulty progression
   - Screen transitions
   - Death mechanics

## Notes
- Maintain component independence
- Keep physics calculations efficient
- Ensure smooth state transitions
- Balance gameplay mechanics
- Optimize screen transitions
- Provide clear UI feedback 