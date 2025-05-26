# System Patterns

## Architecture Overview
The FPS engine follows a modular architecture with clear separation of concerns:

1. **Core Engine**
   - Vector mathematics
   - Camera system
   - Player controls
   - World rendering

2. **Game Loop**
   - Update cycle
   - Render cycle
   - Input handling

## Design Patterns

### Object-Oriented Patterns
- **Prototype Pattern**: Used for Vector3, Camera, and Player classes
- **Component Pattern**: Entities composed of position, rotation, and behavior

### Movement System
- Ground-based movement only
- Relative to camera direction
- Normalized movement vectors
- Fixed vertical position

### Camera System
- First-person perspective
- Euler angles for rotation
- Clamped pitch rotation
- Normalized view vectors

### Rendering System
- 2D projection of 3D space
- Grid-based world
- Perspective projection
- Depth-based rendering

## Component Relationships

### Player-Camera Relationship
```
Player
  ├── Position (Vector3)
  ├── Rotation (yaw, pitch)
  └── Camera
      ├── View Matrix
      ├── Forward Vector
      └── Right Vector
```

### Movement System
```
Input
  ├── Keyboard (WASD)
  └── Mouse (look)
      └── Player
          ├── Position Update
          └── Camera Update
```

### World System
```
Engine
  └── World
      ├── Floor Grid
      └── Rendering
          ├── Projection
          └── Depth Check
```

## Critical Paths

### Movement Update
1. Input processing
2. Direction calculation
3. Position update
4. Camera update

### Rendering Pipeline
1. View matrix calculation
2. World-to-screen projection
3. Depth sorting
4. Grid rendering

## Implementation Guidelines

### Vector Operations
- Use Vector3 class for all 3D math
- Normalize vectors when needed
- Keep operations minimal

### Camera Control
- Clamp pitch to prevent flipping
- Normalize view vectors
- Update position with player

### Movement Control
- Ground-based movement only
- Normalize movement vectors
- Relative to camera direction

## Extension Points

### New Features
- Additional movement types
- Enhanced rendering
- New entity types
- Advanced camera modes

### System Improvements
- Better performance
- More accurate projection
- Enhanced controls
- Additional visual features 