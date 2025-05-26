# Technical Context

## Technologies Used
1. Core Framework
   - LÖVE2D 11.4
   - Lua 5.4
   - Box2D physics engine
   - Custom physics implementation

2. Development Tools
   - Visual Studio Code
   - LÖVE2D debug tools
   - Git version control
   - Custom debug overlays

3. Asset Management
   - LÖVE2D image loading
   - Custom sprite handling
   - Physics body creation
   - UI element management

## Development Setup
1. Project Structure
   ```
   src/
   ├── components/
   │   ├── player.lua
   │   ├── platform.lua
   │   ├── obstacle.lua
   │   └── winZone.lua
   ├── systems/
   │   ├── health.lua
   │   └── screen.lua
   ├── utils/
   │   └── debug.lua
   └── main.lua
   ```

2. Dependencies
   - LÖVE2D 11.4
   - Box2D physics
   - Custom physics system
   - Screen management system

3. Build Process
   - LÖVE2D packaging
   - Asset bundling
   - Debug mode toggle
   - Screen transition handling

## Technical Constraints
1. Physics
   - Box2D limitations
   - Custom gravity implementation
   - Collision handling
   - Camera scrolling
   - Screen transitions

2. Performance
   - Frame rate target: 60 FPS
   - Physics calculations
   - Screen transitions
   - UI updates
   - Memory management

3. Platform
   - Windows compatibility
   - LÖVE2D requirements
   - Screen resolution handling
   - Input management
   - UI scaling

## Tool Usage Patterns
1. LÖVE2D
   - Physics world management
   - Screen transitions
   - Camera control
   - UI rendering
   - Input handling
   - Debug drawing

2. Box2D
   - Body creation
   - Collision detection
   - Physics simulation
   - Camera scrolling
   - Screen management

3. Custom Systems
   - Health management
   - Screen transitions
   - UI positioning
   - Death handling
   - Respawn mechanics
   - Debug overlays

## Development Workflow
1. Code Organization
   - Component-based architecture
   - System separation
   - Screen management
   - UI handling
   - State management

2. Testing
   - Manual gameplay testing
   - Physics verification
   - Screen transition testing
   - UI validation
   - Death mechanics testing

3. Debug Tools
   - Visual debug overlays
   - Physics visualization
   - Screen transition debugging
   - UI element inspection
   - State monitoring

## Notes
- Maintain consistent physics behavior
- Optimize screen transitions
- Ensure smooth UI updates
- Handle death mechanics properly
- Manage screen state effectively
- Provide clear debug information 