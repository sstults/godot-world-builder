extends Camera3D

# Camera follow settings
@export var target: Node3D
@export var follow_distance = 10.0
@export var follow_height = 5.0
@export var follow_speed = 5.0
@export var look_ahead_distance = 2.0

# Mouse look settings
@export var mouse_sensitivity = 0.002
@export var mouse_look_enabled = true
@export var vertical_angle_limit = 80.0

var target_position: Vector3
var mouse_delta = Vector2.ZERO
var camera_rotation = Vector3.ZERO
var ui_is_open = false

func _ready():
	if not target:
		# Try to find player in scene
		target = get_tree().get_first_node_in_group("player")
		if not target:
			print("Warning: No target set for camera controller")
	
	# Capture mouse for look controls
	if mouse_look_enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Only handle mouse look when UI is not open
	if mouse_look_enabled and not ui_is_open and event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_delta += event.relative

func _process(delta):
	if not target:
		return
	
	# Handle mouse look
	handle_mouse_look(delta)
	
	# Calculate desired camera position based on current rotation
	var target_pos = target.global_position
	var desired_position = calculate_camera_position(target_pos)
	
	# Add look-ahead based on player velocity if available
	if target.has_method("get_velocity"):
		var velocity = target.get_velocity()
		if velocity.length() > 0.1:  # Only apply look-ahead if moving
			desired_position += velocity.normalized() * look_ahead_distance
	
	# Smoothly interpolate to desired position
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	
	# Look at the target
	look_at(target_pos, Vector3.UP)

func handle_mouse_look(delta):
	if mouse_delta.length() > 0:
		# Apply mouse movement to camera rotation
		camera_rotation.y -= mouse_delta.x * mouse_sensitivity
		camera_rotation.x -= mouse_delta.y * mouse_sensitivity
		
		# Clamp vertical rotation
		camera_rotation.x = clamp(camera_rotation.x, 
			-deg_to_rad(vertical_angle_limit), 
			deg_to_rad(vertical_angle_limit))
		
		mouse_delta = Vector2.ZERO

func calculate_camera_position(target_pos: Vector3) -> Vector3:
	# Create rotation matrix from camera rotation
	var rotation_transform = Transform3D()
	rotation_transform = rotation_transform.rotated(Vector3.UP, camera_rotation.y)
	rotation_transform = rotation_transform.rotated(Vector3.RIGHT, camera_rotation.x)
	
	# Calculate offset from target
	var offset = Vector3(0, follow_height, follow_distance)
	offset = rotation_transform * offset
	
	return target_pos + offset

func _unhandled_input(event):
	# Only handle escape key when UI is not managing mouse mode
	if event.is_action_pressed("ui_cancel") and not ui_is_open:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called by UI Manager when UI state changes
func _on_ui_state_changed(is_open: bool):
	ui_is_open = is_open
	print("Camera controller: UI state changed to ", "open" if is_open else "closed")
