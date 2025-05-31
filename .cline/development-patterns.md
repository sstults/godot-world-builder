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

## Advanced Patterns (Phase 1)

### Class-based Systems
```gdscript
# Define custom classes for reusable systems
class_name SystemName
extends Node3D

# Add to groups for easy access
func _ready():
    add_to_group("system_group")
```

### Camera Controller Pattern
```gdscript
# Mouse look with rotation limits
func handle_mouse_look(delta):
    if mouse_delta.length() > 0:
        camera_rotation.y -= mouse_delta.x * mouse_sensitivity
        camera_rotation.x -= mouse_delta.y * mouse_sensitivity
        camera_rotation.x = clamp(camera_rotation.x, 
            -deg_to_rad(vertical_angle_limit), 
            deg_to_rad(vertical_angle_limit))
        mouse_delta = Vector2.ZERO
```

### Terrain Generation Pattern
```gdscript
# Procedural mesh generation
func generate_heightmap_mesh() -> ArrayMesh:
    var array_mesh = ArrayMesh.new()
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    
    var vertices = PackedVector3Array()
    var normals = PackedVector3Array()
    var uvs = PackedVector2Array()
    var indices = PackedInt32Array()
    
    # Generate geometry...
    
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_NORMAL] = normals
    arrays[Mesh.ARRAY_TEX_UV] = uvs
    arrays[Mesh.ARRAY_INDEX] = indices
    
    array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return array_mesh
```

### Scene Management Pattern
```gdscript
# Async scene loading with error handling
func load_scene_async(scene_path: String) -> bool:
    if loading_thread and loading_thread.is_alive():
        push_warning("Scene loading already in progress")
        return false
    
    loading_thread = Thread.new()
    loading_thread.start(_async_load_worker.bind(scene_path))
    return true
```

### Player Movement Pattern
```gdscript
# Camera-relative movement
func get_movement_direction(input_dir: Vector2) -> Vector3:
    var direction = Vector3.ZERO
    
    if use_camera_relative_movement and camera:
        var camera_transform = camera.global_transform
        var camera_forward = -camera_transform.basis.z
        var camera_right = camera_transform.basis.x
        
        camera_forward.y = 0
        camera_right.y = 0
        camera_forward = camera_forward.normalized()
        camera_right = camera_right.normalized()
        
        direction = camera_forward * -input_dir.y + camera_right * input_dir.x
    else:
        direction = Vector3(input_dir.x, 0, input_dir.y)
    
    return direction.normalized()
```

### Environment Setup Pattern
```gdscript
# Enhanced lighting and environment
func create_lighting():
    # Primary directional light with shadows
    var sun_light = DirectionalLight3D.new()
    sun_light.shadow_enabled = true
    sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    
    # Secondary fill light for ambient
    var ambient_light = DirectionalLight3D.new()
    ambient_light.light_energy = 0.3
    ambient_light.light_color = Color(0.8, 0.9, 1.0)
    
    # Procedural sky with fog
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.fog_enabled = true
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
```

### Error Handling Pattern
```gdscript
# Comprehensive error handling with signals
signal operation_failed(error_message: String)

func safe_operation() -> bool:
    if not validate_preconditions():
        push_error("Preconditions failed")
        operation_failed.emit("Preconditions not met")
        return false
    
    # Perform operation...
    
    if not verify_result():
        push_error("Operation verification failed")
        operation_failed.emit("Result verification failed")
        return false
    
    return true
```

### Performance Optimization Patterns
```gdscript
# Cache frequently used references
@onready var cached_nodes = {
    "player": get_tree().get_first_node_in_group("player"),
    "camera": get_viewport().get_camera_3d()
}

# Use object pooling for frequently created/destroyed objects
var object_pool = []
var pool_size = 100

func get_pooled_object():
    if object_pool.size() > 0:
        return object_pool.pop_back()
    else:
        return create_new_object()

func return_to_pool(obj):
    obj.reset()
    object_pool.append(obj)
```

## Crafting System Patterns (Phase 2)

### Item Definition Pattern
```gdscript
# Define items as resources
class_name Item
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var max_stack_size: int = 64
@export var rarity: ItemRarity = ItemRarity.COMMON

enum ItemRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
```

### Recipe Definition Pattern
```gdscript
# Flexible recipe system with fluent interface
class_name CraftingRecipe
extends Resource

@export var required_materials: Dictionary = {}
@export var output_items: Dictionary = {}

func add_required_material(item_id: String, quantity: int) -> CraftingRecipe:
    required_materials[item_id] = quantity
    return self

func add_output_item(item_id: String, quantity: int) -> CraftingRecipe:
    output_items[item_id] = quantity
    return self
```

### Crafting Manager Pattern
```gdscript
# Central crafting system with signals
class_name CraftingManager
extends Node

signal crafting_started(recipe: CraftingRecipe)
signal crafting_completed(recipe: CraftingRecipe, output_items: Dictionary)
signal crafting_failed(recipe: CraftingRecipe, reason: String)

var recipes: Dictionary = {}
var items: Dictionary = {}
var active_crafting: Dictionary = {}

func start_crafting(recipe_id: String, available_materials: Dictionary) -> int:
    # Validation and async crafting logic
    var timer = Timer.new()
    timer.timeout.connect(_on_crafting_completed.bind(crafting_id))
    add_child(timer)
    timer.start()
```

### Resource Registration Pattern
```gdscript
# Safe resource registration with validation
func register_item(item: Item) -> bool:
    if not item.is_valid():
        push_error("Cannot register invalid item: " + str(item.id))
        return false
    
    if items.has(item.id):
        push_warning("Item already registered: " + item.id)
        return false
    
    items[item.id] = item
    return true
```

### Crafting Validation Pattern
```gdscript
# Material availability checking
func can_craft_recipe(recipe: CraftingRecipe, available_materials: Dictionary) -> bool:
    for item_id in recipe.required_materials:
        var required_amount = recipe.required_materials[item_id]
        var available_amount = available_materials.get(item_id, 0)
        
        if available_amount < required_amount:
            return false
    
    return true
