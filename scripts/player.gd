extends CharacterBody3D

# Player movement settings
@export var speed = 5.0
@export var run_speed = 8.0
@export var acceleration = 10.0
@export var friction = 10.0
@export var jump_velocity = 8.0
@export var air_control = 0.3

# Camera-relative movement
@export var use_camera_relative_movement = true

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var terrain_generator: Node3D = null
var camera: Camera3D = null

func _ready():
	print("Player initialized")
	# Find terrain generator for ground detection
	terrain_generator = get_tree().get_first_node_in_group("terrain_generator")
	if not terrain_generator:
		# Try to find it by name
		terrain_generator = get_node_or_null("../TerrainGenerator")
	
	# Find camera for relative movement
	camera = get_viewport().get_camera_3d()
	if not camera:
		camera = get_tree().get_first_node_in_group("camera")

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var input_dir = get_input_direction()
	
	# Determine current speed (run vs walk)
	var current_speed = run_speed if Input.is_action_pressed("run") else speed
	
	# Handle movement
	var control_factor = air_control if not is_on_floor() else 1.0
	
	if input_dir != Vector2.ZERO:
		var direction = get_movement_direction(input_dir)
		var target_velocity = direction * current_speed
		
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta * control_factor)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta * control_factor)
		
		# Rotate player to face movement direction
		if direction.length() > 0.1:
			var target_rotation = atan2(-direction.x, -direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta * control_factor)
		velocity.z = move_toward(velocity.z, 0, friction * delta * control_factor)

	move_and_slide()
	
	# Snap to terrain if close enough (for better ground following)
	snap_to_terrain()

func get_input_direction() -> Vector2:
	var input_vector = Vector2()
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_backward"):
		input_vector.y += 1
	if Input.is_action_pressed("move_forward"):
		input_vector.y -= 1
		
	return input_vector.normalized()

func get_movement_direction(input_dir: Vector2) -> Vector3:
	var direction = Vector3.ZERO
	
	if use_camera_relative_movement and camera:
		# Get camera's forward and right vectors (ignoring Y rotation)
		var camera_transform = camera.global_transform
		var camera_forward = -camera_transform.basis.z
		var camera_right = camera_transform.basis.x
		
		# Flatten to horizontal plane
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction relative to camera
		direction = camera_forward * -input_dir.y + camera_right * input_dir.x
	else:
		# Use world-relative movement
		direction = Vector3(input_dir.x, 0, input_dir.y)
	
	return direction.normalized()

func snap_to_terrain():
	# If we have a terrain generator, try to snap to terrain height
	if terrain_generator and terrain_generator.has_method("get_height_at_position"):
		var terrain_height = terrain_generator.get_height_at_position(global_position)
		var ground_distance = global_position.y - terrain_height
		
		# If we're close to the ground and not jumping, snap to terrain
		if ground_distance < 2.0 and ground_distance > 0.1 and velocity.y <= 0:
			if is_on_floor():
				global_position.y = terrain_height + 1.0  # Player height offset

# Get current velocity for camera look-ahead
func get_velocity() -> Vector3:
	return velocity

# Debug information
func _input(event):
	if event.is_action_pressed("ui_select"):  # Tab key by default
		print("Player Debug Info:")
		print("  Position: ", global_position)
		print("  Velocity: ", velocity)
		print("  On Floor: ", is_on_floor())
		if terrain_generator:
			print("  Terrain Height: ", terrain_generator.get_height_at_position(global_position))
