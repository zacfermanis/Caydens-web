# Technical Context

## Technology Stack
- **Language**: Lua 5.1+
- **Framework**: LÖVE (Love2D)
- **Development Environment**: Any text editor with Lua support

## Core Components

### Vector3 System
- Custom Vector3 class for 3D mathematics
- Supports basic operations: add, subtract, multiply
- Used for positions, directions, and calculations

### Camera System
- First-person camera implementation
- Field of view: 70 degrees
- Near plane: 0.1
- Far plane: 1000
- Supports yaw and pitch rotation

### Player System
- Eye level position (y = 1.7)
- Movement speed: 5.0 units/second
- Mouse sensitivity: 0.1
- Ground-based movement (y position fixed)
- WASD controls with inverted W/S

### World System
- Grid-based floor
- Size: 100 units (half-width)
- Grid cell size: 10 units
- Dark gray grid lines

## Development Setup
1. Install LÖVE framework
2. Clone repository
3. Run with `love .` command

## Dependencies
- LÖVE framework (latest stable version)

## Technical Constraints
- 2D rendering of 3D space
- Fixed perspective projection
- Ground-based movement only
- No vertical movement

## Performance Considerations
- Grid rendering optimized for view distance
- Vector operations kept minimal
- No complex physics calculations

## Code Organization
- `engine.lua`: Core engine functionality
- `main.lua`: Game initialization and loop
- Memory Bank: Project documentation

## Testing Strategy
- Manual testing of movement and controls
- Visual verification of grid rendering
- Performance monitoring during movement

## Known Technical Limitations
- No true 3D rendering
- Limited to ground plane movement
- Basic collision detection
- No vertical movement support 