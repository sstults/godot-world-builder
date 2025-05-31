extends Camera3D

# Camera follow settings
@export var target: Node3D
@export var follow_distance = 10.0
@export var follow_height = 5.0
@export var follow_speed = 5.0
@export var look_ahead_distance = 2.0

var target_position: Vector3

func _ready():
	if not target:
		# Try to find player in scene
		target = get_tree().get_first_node_in_group("player")
		if not target:
			print("Warning: No target set for camera controller")

func _process(delta):
	if not target:
		return
		
	# Calculate desired camera position
	var target_pos = target.global_position
	var desired_position = target_pos + Vector3(0, follow_height, follow_distance)
	
	# Add look-ahead based on player velocity if available
	if target.has_method("get_velocity"):
		var velocity = target.get_velocity()
		if velocity.length() > 0.1:  # Only apply look-ahead if moving
			desired_position += velocity.normalized() * look_ahead_distance
	
	# Smoothly interpolate to desired position
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	
	# Always look at the target
	look_at(target_pos, Vector3.UP)
