class_name GatherableResource
extends RigidBody3D

# Resource properties
@export var resource_id: String = "wood"
@export var resource_name: String = "Tree"
@export var harvest_amount_min: int = 1
@export var harvest_amount_max: int = 3
@export var harvest_time: float = 2.0
@export var respawn_time: float = 30.0
@export var max_health: int = 3
@export var interaction_distance: float = 3.0

# Visual properties
@export var normal_color: Color = Color.WHITE
@export var highlight_color: Color = Color.YELLOW
@export var harvesting_color: Color = Color.ORANGE

# Signals
signal resource_harvested(resource_id: String, amount: int)
signal resource_depleted(resource: GatherableResource)
signal interaction_started(resource: GatherableResource)
signal interaction_ended(resource: GatherableResource)

# Internal state
var current_health: int
var is_respawning: bool = false
var is_being_harvested: bool = false
var harvest_progress: float = 0.0
var is_highlighted: bool = false

# Node references
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var harvest_timer: Timer
var respawn_timer: Timer
var material: StandardMaterial3D

func _ready():
	# Initialize health
	current_health = max_health
	
	# Set up the resource
	create_visual_representation()
	create_collision()
	create_timers()
	
	# Configure RigidBody3D
	gravity_scale = 1.0
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true  # Resources don't move
	
	# Add to interaction group
	add_to_group("gatherable_resources")
	
	print("GatherableResource initialized: ", resource_name, " (", resource_id, ")")

func create_visual_representation():
	# Create mesh instance
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	
	# Create different meshes based on resource type
	var mesh: Mesh
	match resource_id:
		"wood":
			# Tree-like mesh (cylinder with sphere on top)
			mesh = create_tree_mesh()
		"stone":
			# Rock-like mesh (sphere)
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.8
			sphere_mesh.height = 1.6
			mesh = sphere_mesh
		_:
			# Default box mesh
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3(1, 1, 1)
			mesh = box_mesh
	
	mesh_instance.mesh = mesh
	
	# Create material
	material = StandardMaterial3D.new()
	material.albedo_color = normal_color
	material.metallic = 0.0
	material.roughness = 0.8
	mesh_instance.material_override = material
	
	add_child(mesh_instance)

func create_tree_mesh() -> ArrayMesh:
	# Create a simple tree shape (cylinder trunk + sphere foliage)
	var array_mesh = ArrayMesh.new()
	
	# Create trunk (cylinder)
	var trunk_arrays = []
	trunk_arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Simple cylinder for trunk
	var radius = 0.3
	var height = 2.0
	var segments = 8
	
	# Generate cylinder geometry
	for i in range(segments + 1):
		var angle = i * TAU / segments
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		
		# Bottom vertices
		vertices.append(Vector3(x, 0, z))
		normals.append(Vector3(x, 0, z).normalized())
		uvs.append(Vector2(float(i) / segments, 0))
		
		# Top vertices
		vertices.append(Vector3(x, height, z))
		normals.append(Vector3(x, 0, z).normalized())
		uvs.append(Vector2(float(i) / segments, 1))
	
	# Generate indices for cylinder walls
	for i in range(segments):
		var bottom1 = i * 2
		var top1 = i * 2 + 1
		var bottom2 = ((i + 1) % (segments + 1)) * 2
		var top2 = ((i + 1) % (segments + 1)) * 2 + 1
		
		# Triangle 1
		indices.append(bottom1)
		indices.append(top1)
		indices.append(bottom2)
		
		# Triangle 2
		indices.append(bottom2)
		indices.append(top1)
		indices.append(top2)
	
	trunk_arrays[Mesh.ARRAY_VERTEX] = vertices
	trunk_arrays[Mesh.ARRAY_NORMAL] = normals
	trunk_arrays[Mesh.ARRAY_TEX_UV] = uvs
	trunk_arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, trunk_arrays)
	return array_mesh

func create_collision():
	# Create collision shape
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	
	# Use appropriate collision shape based on resource type
	var shape: Shape3D
	match resource_id:
		"wood":
			var capsule_shape = CapsuleShape3D.new()
			capsule_shape.radius = 0.5
			capsule_shape.height = 2.0
			shape = capsule_shape
		"stone":
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = 0.8
			shape = sphere_shape
		_:
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(1, 1, 1)
			shape = box_shape
	
	collision_shape.shape = shape
	add_child(collision_shape)

func create_timers():
	# Create harvest timer
	harvest_timer = Timer.new()
	harvest_timer.name = "HarvestTimer"
	harvest_timer.wait_time = harvest_time
	harvest_timer.one_shot = true
	harvest_timer.timeout.connect(_on_harvest_completed)
	add_child(harvest_timer)
	
	# Create respawn timer
	respawn_timer = Timer.new()
	respawn_timer.name = "RespawnTimer"
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_on_respawn_completed)
	add_child(respawn_timer)

# Interaction methods
func can_be_harvested() -> bool:
	return current_health > 0 and not is_respawning and not is_being_harvested

func start_harvesting() -> bool:
	if not can_be_harvested():
		return false
	
	is_being_harvested = true
	harvest_progress = 0.0
	
	# Visual feedback
	set_visual_state("harvesting")
	
	# Start harvest timer
	harvest_timer.start()
	
	# Emit signal
	interaction_started.emit(self)
	
	print("Started harvesting: ", resource_name)
	return true

func cancel_harvesting():
	if not is_being_harvested:
		return
	
	is_being_harvested = false
	harvest_progress = 0.0
	
	# Stop timer
	harvest_timer.stop()
	
	# Reset visual state
	set_visual_state("normal")
	
	# Emit signal
	interaction_ended.emit(self)
	
	print("Cancelled harvesting: ", resource_name)

func set_highlighted(highlighted: bool):
	if highlighted == is_highlighted:
		return
	
	is_highlighted = highlighted
	
	if not is_being_harvested:
		if highlighted:
			set_visual_state("highlighted")
		else:
			set_visual_state("normal")

func set_visual_state(state: String):
	if not material:
		return
	
	match state:
		"normal":
			material.albedo_color = normal_color
		"highlighted":
			material.albedo_color = highlight_color
		"harvesting":
			material.albedo_color = harvesting_color

func get_harvest_amount() -> int:
	return randi_range(harvest_amount_min, harvest_amount_max)

func get_interaction_distance() -> float:
	return interaction_distance

func get_resource_info() -> Dictionary:
	return {
		"id": resource_id,
		"name": resource_name,
		"health": current_health,
		"max_health": max_health,
		"can_harvest": can_be_harvested(),
		"is_respawning": is_respawning,
		"harvest_time": harvest_time
	}

# Timer callbacks
func _on_harvest_completed():
	if not is_being_harvested:
		return
	
	# Calculate harvest amount
	var amount = get_harvest_amount()
	
	# Reduce health
	current_health -= 1
	
	# Emit harvest signal
	resource_harvested.emit(resource_id, amount)
	
	# End harvesting state
	is_being_harvested = false
	harvest_progress = 1.0
	interaction_ended.emit(self)
	
	print("Harvested ", amount, "x ", resource_id, " from ", resource_name)
	
	# Check if resource is depleted
	if current_health <= 0:
		start_respawning()
	else:
		set_visual_state("normal")

func start_respawning():
	if is_respawning:
		return
	
	is_respawning = true
	
	# Hide the resource visually
	if mesh_instance:
		mesh_instance.visible = false
	
	# Disable collision
	if collision_shape:
		collision_shape.disabled = true
	
	# Start respawn timer
	respawn_timer.start()
	
	# Emit depletion signal
	resource_depleted.emit(self)
	
	print("Resource depleted, respawning in ", respawn_time, " seconds: ", resource_name)

func _on_respawn_completed():
	if not is_respawning:
		return
	
	# Reset health
	current_health = max_health
	is_respawning = false
	
	# Show the resource
	if mesh_instance:
		mesh_instance.visible = true
	
	# Enable collision
	if collision_shape:
		collision_shape.disabled = false
	
	# Reset visual state
	set_visual_state("normal")
	
	print("Resource respawned: ", resource_name)

# Update harvest progress for visual feedback
func _process(delta):
	if is_being_harvested and harvest_timer:
		harvest_progress = 1.0 - (harvest_timer.time_left / harvest_time)

# Static factory methods for common resource types
static func create_tree(pos: Vector3) -> GatherableResource:
	var tree = GatherableResource.new()
	tree.resource_id = "wood"
	tree.resource_name = "Tree"
	tree.harvest_amount_min = 2
	tree.harvest_amount_max = 4
	tree.harvest_time = 3.0
	tree.respawn_time = 45.0
	tree.max_health = 3
	tree.normal_color = Color(0.4, 0.2, 0.1)  # Brown
	tree.highlight_color = Color(0.8, 0.6, 0.2)  # Light brown
	tree.position = pos
	return tree

static func create_rock(pos: Vector3) -> GatherableResource:
	var rock = GatherableResource.new()
	rock.resource_id = "stone"
	rock.resource_name = "Rock"
	rock.harvest_amount_min = 1
	rock.harvest_amount_max = 2
	rock.harvest_time = 2.0
	rock.respawn_time = 60.0
	rock.max_health = 2
	rock.normal_color = Color(0.5, 0.5, 0.5)  # Gray
	rock.highlight_color = Color(0.8, 0.8, 0.6)  # Light gray
	rock.position = pos
	return rock
