# System Patterns

## Architecture Overview
1. Component-Based Design
   - Player component
   - Platform component
   - Obstacle component
   - Win zone component
   - Health system

2. Physics System
   - LÖVE2D physics engine
   - Custom gravity implementation
   - Collision detection
   - Momentum preservation

3. State Management
   - Game state tracking
   - Level progression
   - Health management
   - Player state

## Key Technical Decisions
1. Movement System
   - Independent horizontal/vertical controls
   - Physics-based movement
   - Air control mechanics
   - Momentum preservation
   - Ground detection

2. Health System
   - Simple health points
   - Visual health bar
   - Collision-based damage
   - Death and respawn mechanics

3. Level Generation
   - Procedural platform placement
   - Zigzag pattern generation
   - Progressive difficulty scaling
   - Extended vertical levels

4. Obstacle System
   - Physics-based obstacles
   - Collision damage
   - Spawn management
   - Difficulty scaling

## Component Relationships
1. Player Interactions
   - Platform collision
   - Obstacle damage
   - Win zone detection
   - Health management

2. Level Structure
   - Platform generation
   - Obstacle spawning
   - Win zone placement
   - Player spawn point

3. Game Flow
   - Level progression
   - Health management
   - Death and respawn
   - Win condition

## Critical Implementation Paths
1. Movement
   - Horizontal movement (A/D)
   - Jumping (Space)
   - Boost jumps (W)
   - Air control

2. Health
   - Health bar display
   - Damage calculation
   - Death handling
   - Respawn mechanics

3. Level Design
   - Platform generation
   - Obstacle placement
   - Win zone positioning
   - Difficulty scaling

## Design Patterns
1. Component Pattern
   - Modular game objects
   - Reusable components
   - Clear separation of concerns

2. State Pattern
   - Game state management
   - Player state handling
   - Level state tracking

3. Observer Pattern
   - Collision detection
   - Health updates
   - Win condition checking

## Technical Constraints
1. Physics
   - LÖVE2D physics limitations
   - Custom gravity implementation
   - Collision handling

2. Performance
   - Obstacle management
   - Platform generation
   - Physics calculations

3. Gameplay
   - Movement responsiveness
   - Health balance
   - Difficulty progression

## Notes
- Maintain component independence
- Keep physics calculations efficient
- Ensure smooth state transitions
- Balance gameplay mechanics 