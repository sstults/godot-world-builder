extends Node3D

# Main scene controller - handles scene initialization

func _ready():
	print("Main scene loaded - World Builder 3D")
	setup_scene()

func setup_scene():
	# Create basic lighting
	create_lighting()
	
	# Create simple terrain
	create_terrain()
	
	# Create player
	create_player()
	
	# Create camera
	create_camera()

func create_lighting():
	# Add directional light (sun)
	var light = DirectionalLight3D.new()
	light.name = "Sun"
	light.position = Vector3(0, 10, 0)
	light.rotation_degrees = Vector3(-45, 45, 0)
	light.light_energy = 1.0
	add_child(light)
	
	# Add environment for sky
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	
	var camera_env = get_viewport().environment
	if not camera_env:
		get_viewport().environment = env

func create_terrain():
	# Create a simple plane for terrain
	var terrain_body = StaticBody3D.new()
	terrain_body.name = "Terrain"
	
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(100, 100)
	plane_mesh.subdivide_width = 10
	plane_mesh.subdivide_depth = 10
	mesh_instance.mesh = plane_mesh
	
	# Create collision shape
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(100, 0.1, 100)
	collision_shape.shape = shape
	collision_shape.position = Vector3(0, -0.05, 0)
	
	terrain_body.add_child(mesh_instance)
	terrain_body.add_child(collision_shape)
	add_child(terrain_body)
	
	print("Terrain created: 100x100 plane")

func create_player():
	# Create player character (simple cube for now)
	var player = CharacterBody3D.new()
	player.name = "Player"
	player.add_to_group("player")
	
	# Add mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 2, 1)
	mesh_instance.mesh = box_mesh
	
	# Add collision
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 2, 1)
	collision_shape.shape = shape
	
	# Position player above terrain
	player.position = Vector3(0, 2, 0)
	
	player.add_child(mesh_instance)
	player.add_child(collision_shape)
	
	# Add movement script
	var script = load("res://scripts/player.gd")
	player.set_script(script)
	
	add_child(player)
	print("Player created at position: ", player.position)

func create_camera():
	# Create camera with follow script
	var camera = Camera3D.new()
	camera.name = "FollowCamera"
	camera.position = Vector3(0, 10, 15)
	
	# Add camera controller script
	var script = load("res://scripts/camera_controller.gd")
	camera.set_script(script)
	
	# Set target to player
	var player = get_node("Player")
	camera.set("target", player)
	
	add_child(camera)
	print("Camera created with follow target")
