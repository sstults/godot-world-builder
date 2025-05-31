class_name InteractionManager
extends Node

# Interaction settings
@export var interaction_check_radius: float = 5.0
@export var max_interaction_distance: float = 3.0
@export var interaction_raycast_enabled: bool = true

# Signals
signal interaction_target_changed(new_target: GatherableResource)
signal interaction_started(resource: GatherableResource)
signal interaction_completed(resource: GatherableResource, items: Dictionary)
signal interaction_cancelled(resource: GatherableResource)

# References
var player: CharacterBody3D
var inventory: Inventory
var camera: Camera3D

# Interaction state
var current_target: GatherableResource = null
var current_interaction: GatherableResource = null
var nearby_resources: Array[GatherableResource] = []

# Internal components
var interaction_area: Area3D
var collision_shape: CollisionShape3D
var raycast: RayCast3D

func _ready():
	# Find required components
	setup_references()
	
	# Create interaction detection area
	create_interaction_area()
	
	# Create raycast for line-of-sight checking
	create_raycast()
	
	# Add to interaction group
	add_to_group("interaction_manager")
	
	print("InteractionManager initialized")

func setup_references():
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("InteractionManager: Player not found!")
	
	# Find inventory
	inventory = get_tree().get_first_node_in_group("inventory")
	if not inventory:
		# Try to find by name
		inventory = get_node_or_null("../PlayerInventory")
	if not inventory:
		push_error("InteractionManager: Inventory not found!")
	
	# Find camera
	camera = get_viewport().get_camera_3d()
	if not camera:
		camera = get_tree().get_first_node_in_group("camera")

func create_interaction_area():
	# Create area for detecting nearby resources
	interaction_area = Area3D.new()
	interaction_area.name = "InteractionArea"
	
	# Create collision shape
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_check_radius
	collision_shape.shape = sphere_shape
	
	interaction_area.add_child(collision_shape)
	add_child(interaction_area)
	
	# Connect signals
	interaction_area.body_entered.connect(_on_resource_entered_range)
	interaction_area.body_exited.connect(_on_resource_exited_range)
	
	# Configure collision layers (only detect gatherable resources)
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 1  # Assuming resources are on layer 1

func create_raycast():
	# Create raycast for line-of-sight checking
	raycast = RayCast3D.new()
	raycast.name = "InteractionRaycast"
	raycast.enabled = interaction_raycast_enabled
	add_child(raycast)

func _process(delta):
	if not player:
		return
	
	# Update interaction area position
	if interaction_area:
		interaction_area.global_position = player.global_position
	
	# Update current target based on closest valid resource
	update_interaction_target()
	
	# Update raycast if we have a target
	update_raycast()

func update_interaction_target():
	var best_target: GatherableResource = null
	var best_distance: float = max_interaction_distance + 1.0
	
	# Check all nearby resources
	for resource in nearby_resources:
		if not is_valid_interaction_target(resource):
			continue
		
		var distance = player.global_position.distance_to(resource.global_position)
		
		# Check if within interaction distance
		if distance <= resource.get_interaction_distance() and distance < best_distance:
			# Check line of sight if raycast is enabled
			if interaction_raycast_enabled and not has_line_of_sight(resource):
				continue
			
			best_target = resource
			best_distance = distance
	
	# Update current target
	if current_target != best_target:
		# Clear highlight from old target
		if current_target:
			current_target.set_highlighted(false)
		
		# Set new target
		current_target = best_target
		
		# Highlight new target
		if current_target:
			current_target.set_highlighted(true)
		
		# Emit signal
		interaction_target_changed.emit(current_target)

func update_raycast():
	if not raycast or not raycast.enabled or not current_target:
		return
	
	# Set raycast from player to target
	var target_position = current_target.global_position
	var player_position = player.global_position + Vector3(0, 1, 0)  # Offset for player height
	
	raycast.global_position = player_position
	raycast.target_position = raycast.to_local(target_position)

func has_line_of_sight(resource: GatherableResource) -> bool:
	if not raycast or not raycast.enabled:
		return true  # Assume line of sight if raycast disabled
	
	var player_position = player.global_position + Vector3(0, 1, 0)  # Player eye height
	var target_position = resource.global_position
	
	# Set up raycast
	raycast.global_position = player_position
	raycast.target_position = raycast.to_local(target_position)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		# Check if we hit the target resource or something else
		return collider == resource
	
	return true  # No obstruction

func is_valid_interaction_target(resource: GatherableResource) -> bool:
	if not resource or not is_instance_valid(resource):
		return false
	
	# Check if resource can be harvested
	return resource.can_be_harvested()

# Interaction methods
func can_interact() -> bool:
	return current_target != null and not current_interaction

func start_interaction() -> bool:
	if not can_interact():
		return false
	
	var target = current_target
	if not target.start_harvesting():
		return false
	
	# Set up interaction state
	current_interaction = target
	
	# Connect to resource signals
	if not target.resource_harvested.is_connected(_on_resource_harvested):
		target.resource_harvested.connect(_on_resource_harvested)
	if not target.interaction_ended.is_connected(_on_interaction_ended):
		target.interaction_ended.connect(_on_interaction_ended)
	
	# Emit signal
	interaction_started.emit(target)
	
	print("Started interaction with: ", target.resource_name)
	return true

func cancel_interaction():
	if not current_interaction:
		return
	
	var resource = current_interaction
	resource.cancel_harvesting()
	
	# Clean up
	cleanup_interaction(resource)
	
	# Emit signal
	interaction_cancelled.emit(resource)
	
	print("Cancelled interaction with: ", resource.resource_name)

func cleanup_interaction(resource: GatherableResource):
	# Disconnect signals
	if resource.resource_harvested.is_connected(_on_resource_harvested):
		resource.resource_harvested.disconnect(_on_resource_harvested)
	if resource.interaction_ended.is_connected(_on_interaction_ended):
		resource.interaction_ended.disconnect(_on_interaction_ended)
	
	# Clear interaction state
	current_interaction = null

# Input handling
func handle_interaction_input():
	if Input.is_action_just_pressed("interact"):
		if current_interaction:
			cancel_interaction()
		elif can_interact():
			start_interaction()

func _input(event):
	# Handle interaction input
	if event.is_action_pressed("interact"):
		handle_interaction_input()

# Signal callbacks
func _on_resource_entered_range(body: Node3D):
	if body is GatherableResource:
		var resource = body as GatherableResource
		if not resource in nearby_resources:
			nearby_resources.append(resource)
			print("Resource entered range: ", resource.resource_name)

func _on_resource_exited_range(body: Node3D):
	if body is GatherableResource:
		var resource = body as GatherableResource
		if resource in nearby_resources:
			nearby_resources.erase(resource)
			print("Resource left range: ", resource.resource_name)
		
		# Clear target if it left range
		if resource == current_target:
			resource.set_highlighted(false)
			current_target = null
			interaction_target_changed.emit(null)

func _on_resource_harvested(resource_id: String, amount: int):
	if not current_interaction or not inventory:
		return
	
	# Add harvested items to inventory
	inventory.add_item(resource_id, amount)
	
	print("Harvested ", amount, "x ", resource_id)

func _on_interaction_ended(resource: GatherableResource):
	if resource != current_interaction:
		return
	
	# Create items dictionary for signal
	var items_gained = {}
	# Note: This would need to be tracked during the harvest process
	# For now, we'll use the resource info
	var info = resource.get_resource_info()
	
	# Clean up interaction
	cleanup_interaction(resource)
	
	# Emit completion signal
	interaction_completed.emit(resource, items_gained)
	
	print("Completed interaction with: ", resource.resource_name)

# Information methods
func get_current_target() -> GatherableResource:
	return current_target

func get_current_interaction() -> GatherableResource:
	return current_interaction

func get_nearby_resources() -> Array[GatherableResource]:
	return nearby_resources.duplicate()

func get_interaction_info() -> Dictionary:
	return {
		"has_target": current_target != null,
		"is_interacting": current_interaction != null,
		"nearby_count": nearby_resources.size(),
		"target_info": current_target.get_resource_info() if current_target else {},
		"interaction_info": current_interaction.get_resource_info() if current_interaction else {}
	}

# Debug methods
func debug_interactions():
	print("\n--- INTERACTION DEBUG ---")
	print("Current target: ", current_target.resource_name if current_target else "None")
	print("Current interaction: ", current_interaction.resource_name if current_interaction else "None")
	print("Nearby resources: ", nearby_resources.size())
	
	for resource in nearby_resources:
		var distance = player.global_position.distance_to(resource.global_position) if player else 0
		print("  - ", resource.resource_name, " (", resource.resource_id, ") - Distance: ", distance)
	
	if current_target:
		var target_info = current_target.get_resource_info()
		print("Target info: ", target_info)
