# Godot Engine Learning Notes

## GDScript Basics

### Key Differences from Other Languages
- Uses `@` for annotations (e.g., `@onready`, `@export`)
- `func _ready():` is the constructor equivalent
- `extends` keyword for inheritance
- Built-in Vector3, Vector2 types for 3D/2D math

### Important Godot 4 Changes
- `instance()` → `instantiate()`
- `connect()` syntax simplified
- New annotation system
- Improved type hints

### Common Gotchas
- Node paths are case-sensitive
- Scene tree ready order matters
- Use `@onready` for node references that need scene tree
- `_process()` vs `_physics_process()` timing differences

## 3D Development Specifics
- CharacterBody3D for player movement
- StaticBody3D for terrain/structures
- RigidBody3D for physics objects
- Camera3D for viewpoint

### Coordinate System
- Y-axis is up
- Right-handed coordinate system
- Transform3D for positioning/rotation
