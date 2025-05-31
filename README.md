# World Builder 3D

A procedurally generated 3D world with crafting and interaction systems, built entirely through code in Godot 4.x.

## Project Overview

This project demonstrates a comprehensive 3D game featuring:
- Procedural terrain generation using noise-based heightmaps
- 3rd person character with movement, camera, and interaction systems
- Complete crafting system with items, recipes, and inventory management
- Object interaction system for resource gathering
- Full UI system for inventory and crafting management
- Extensible AI development knowledge base
- Complete code-only development workflow

## Development Philosophy

- **Code-Only**: No GUI editor usage for core development
- **AI-Reviewable**: Every commit documented for AI review and learning
- **Iterative**: Build in small, testable increments
- **Extensible**: Design for future expansion and modification
- **Signal-Driven**: Loose coupling for maintainable architecture

## Current Status

**Phase 2: Crafting & Interaction Systems** (In Progress)
- ✅ **Phase 0**: Environment Setup (Complete)
- ✅ **Phase 1**: Core Systems Development (Complete)
- 🟡 **Phase 2**: Crafting & Interaction Systems (In Progress)

### Completed Features
- **Player System**: 3D character with movement, jump, run mechanics
- **Camera System**: 3rd person with mouse look and smooth following
- **Terrain System**: Procedural generation with collision and materials
- **Scene Management**: Async loading system for modular scenes
- **Crafting System**: Items, recipes, and crafting manager with validation
- **Inventory System**: Item storage with stack management and UI integration
- **Interaction System**: Resource gathering with proximity detection and visual feedback
- **UI System**: Inventory and crafting panels with real-time updates

### Current Gameplay Loop
1. **Explore**: Move around procedurally generated terrain
2. **Gather**: Press F near trees/rocks to harvest materials (Wood, Stone)
3. **Inventory**: Press I to view collected materials
4. **Craft**: Press C to access crafting recipes (Sticks, Wooden Pickaxe)
5. **Repeat**: Complete gameplay cycle with resource respawning

## Getting Started

### Prerequisites
- Godot 4.x
- Git
- GitHub CLI (gh) [optional]

### Running the Project
```bash
git clone [repository-url]
cd godot-world-builder
godot project.godot
```

### Controls
- **WASD**: Move player
- **Space**: Jump
- **Shift**: Run (hold while moving)
- **Mouse**: Look around (camera control)
- **F**: Interact with highlighted resources
- **I**: Open/close inventory panel
- **C**: Open/close crafting panel
- **Escape**: Close all UI panels
- **Tab**: Toggle debug information
- **Enter**: Test crafting system (console)

## Project Structure

```
godot-world-builder/
├── .cline/                    # AI Knowledge Base
│   ├── project-context.md     # Current status and priorities (READ FIRST)
│   ├── milestone-reviews.md   # Progress tracking and lessons learned
│   ├── development-patterns.md # Reusable GDScript patterns
│   └── [other docs]          # Specialized knowledge files
├── scenes/                    # Godot scene files
│   └── main.tscn             # Main game scene
├── scripts/                   # GDScript implementation files
│   ├── main.gd               # Scene coordination
│   ├── player.gd             # Player movement and mechanics
│   ├── camera_controller.gd  # 3rd person camera system
│   ├── terrain_generator.gd  # Procedural terrain
│   ├── crafting_manager.gd   # Crafting system coordination
│   ├── inventory.gd          # Player item storage
│   ├── interaction_manager.gd # Resource gathering system
│   ├── ui_manager.gd         # UI system coordination
│   └── [other scripts]      # Supporting classes
├── assets/                    # Game assets (materials, textures)
├── .github/                   # CI/CD workflows and issue templates
└── docs/                      # Additional documentation
```

## Development Workflow

1. **Context**: Read `.cline/project-context.md` for current priorities
2. **Implementation**: Code-only development with signal-driven architecture
3. **Testing**: Verify functionality in Godot editor with interactive controls
4. **Documentation**: Update `.cline/` knowledge base with patterns and learnings
5. **Commit**: Detailed commit messages for AI-assisted development
6. **Review**: Update milestone progress and troubleshooting guides

## Architecture Highlights

### Signal-Driven Design
- Loose coupling between all major systems
- Event-based communication for UI updates
- Extensible architecture for future features

### Resource-Based Items
- Godot Resource classes for item definitions
- Type-safe crafting with validation
- Extensible item system with rarity and properties

### Modular Systems
- Independent managers for crafting, inventory, interaction, UI
- Group-based automatic system discovery
- Clear separation of concerns

## AI Knowledge Base

The `.cline/` directory contains comprehensive documentation:
- **`project-context.md`**: Current project status and priorities (START HERE)
- **`milestone-reviews.md`**: Detailed progress tracking and lessons learned
- **`development-patterns.md`**: Reusable GDScript and Godot patterns
- **`godot-learnings.md`**: Godot-specific implementation knowledge
- **`troubleshooting.md`**: Known issues and solutions
- **`workflow-guide.md`**: AI interaction patterns and commands

## Next Steps

**Phase 2 Continuation:**
1. Expand crafting recipes and item variety
2. Create crafting stations for advanced recipes
3. Add visual feedback for crafting operations
4. Add sound effects and audio management

**Future Phases:**
- Building and construction systems
- Advanced procedural generation
- Multiplayer capabilities
- Save/load system

## Contributing

This project follows AI-assisted development patterns:
- Read `project-context.md` for current priorities
- Use GitHub issue templates for new tasks
- Update knowledge base with new patterns
- Include comprehensive testing scenarios
- Document architectural decisions

## License

MIT License - See LICENSE file for details
