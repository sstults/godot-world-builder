# Development Patterns

## Godot GDScript Patterns

### Node Creation Pattern
```gdscript
# Always check if node exists before adding
if not has_node("NodeName"):
    var new_node = NodeType.new()
    new_node.name = "NodeName"
    add_child(new_node)
```

### Input Handling Pattern
```gdscript
func _input(event):
    if event.is_action_pressed("action_name"):
        handle_action()
```

### Safe Node Reference Pattern
```gdscript
@onready var node_ref = get_node("path/to/node")
```

## Code-Only Development Patterns

### Scene Creation
1. Create .tscn files programmatically using PackedScene
2. Use `scene.instantiate()` instead of `scene.instance()` in Godot 4
3. Always set node names explicitly for debugging

### Resource Management
- Use `preload()` for assets known at compile time
- Use `load()` for dynamic asset loading
- Cache frequently used resources

## Project Organization
- Keep scripts modular and single-purpose
- Use signals for loose coupling between systems
- Organize by functionality, not file type
