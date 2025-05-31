# World Builder 3D

A procedurally generated 3D world with crafting systems, built entirely through code in Godot.

## Project Overview

This project aims to create a comprehensive 3D game featuring:
- Procedural world generation using Wave Function Collapse
- 3rd person character with crafting abilities
- Extensible AI development knowledge base
- Complete code-only development workflow

## Development Philosophy

- **Code-Only**: No GUI editor usage for core development
- **AI-Reviewable**: Every commit documented for AI review and learning
- **Iterative**: Build in small, testable increments
- **Extensible**: Design for future expansion and modification

## Current Status

**Phase 0: Environment Setup** (In Progress)
- [x] Project structure created
- [x] Basic scene with player movement
- [x] 3rd person camera system
- [x] AI knowledge base initialized
- [ ] GitHub CI/CD setup
- [ ] First milestone testing

## Getting Started

### Prerequisites
- Godot 4.x
- Git
- GitHub CLI (gh)

### Running the Project
```bash
cd godot-world-builder
godot project.godot
```

### Controls
- WASD: Move player
- Camera automatically follows player

## Project Structure

```
godot-world-builder/
├── .cline/                    # AI Knowledge Base
├── scenes/                    # Game scenes
├── scripts/                   # GDScript files
├── assets/                    # Game assets
├── procedural/                # Generation systems
├── docs/                      # Documentation
└── .github/                   # CI/CD workflows
```

## Development Workflow

1. **Issue Creation**: Each task tracked as GitHub issue
2. **Implementation**: Code-only development with detailed comments
3. **Testing**: Verify functionality in Godot
4. **Documentation**: Update `.cline/` knowledge base
5. **Commit**: Detailed commit messages for AI review
6. **Review**: Update milestone progress

## AI Knowledge Base

The `.cline/` directory contains:
- `development-patterns.md`: Reusable code patterns
- `godot-learnings.md`: GDScript and Godot specifics
- `procedural-gen-notes.md`: Generation algorithm details
- `troubleshooting.md`: Common issues and solutions
- `milestone-reviews.md`: Progress tracking and lessons learned

## Contributing

This project follows AI-assisted development patterns. Each change should:
- Include clear commit messages explaining decisions
- Update relevant knowledge base files
- Include test scenarios for verification
- Document any new patterns or learnings

## License

MIT License - See LICENSE file for details
