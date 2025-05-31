extends Node3D
class_name TerrainGenerator

# Terrain settings
@export var terrain_size = Vector2(100, 100)
@export var height_scale = 10.0
@export var subdivisions = Vector2(50, 50)
@export var noise_scale = 0.1
@export var noise_octaves = 4
@export var noise_persistence = 0.5
@export var noise_lacunarity = 2.0

var noise: FastNoiseLite
var terrain_mesh_instance: MeshInstance3D
var terrain_body: StaticBody3D

func _ready():
	# Add to terrain_generator group for easy access
	add_to_group("terrain_generator")
	setup_noise()
	generate_terrain()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	noise.fractal_octaves = noise_octaves
	noise.fractal_gain = noise_persistence
	noise.fractal_lacunarity = noise_lacunarity
	# Use a random seed for variation
	noise.seed = randi() % 10000

func generate_terrain():
	# Create terrain body
	terrain_body = StaticBody3D.new()
	terrain_body.name = "GeneratedTerrain"
	add_child(terrain_body)
	
	# Generate heightmap-based mesh
	var mesh = generate_heightmap_mesh()
	
	# Create mesh instance
	terrain_mesh_instance = MeshInstance3D.new()
	terrain_mesh_instance.mesh = mesh
	terrain_body.add_child(terrain_mesh_instance)
	
	# Create collision shape
	create_collision_shape(mesh)
	
	# Apply basic material
	apply_terrain_material()
	
	print("Generated terrain: ", terrain_size, " with ", subdivisions, " subdivisions")

func generate_heightmap_mesh() -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Generate vertices with height from noise
	var step_x = terrain_size.x / subdivisions.x
	var step_z = terrain_size.y / subdivisions.y
	
	for z in range(int(subdivisions.y) + 1):
		for x in range(int(subdivisions.x) + 1):
			var pos_x = -terrain_size.x / 2 + x * step_x
			var pos_z = -terrain_size.y / 2 + z * step_z
			
			# Sample noise for height
			var height = noise.get_noise_2d(pos_x, pos_z) * height_scale
			
			vertices.append(Vector3(pos_x, height, pos_z))
			uvs.append(Vector2(float(x) / subdivisions.x, float(z) / subdivisions.y))
	
	# Generate indices for triangles
	var width = int(subdivisions.x) + 1
	for z in range(int(subdivisions.y)):
		for x in range(int(subdivisions.x)):
			var i = z * width + x
			
			# First triangle
			indices.append(i)
			indices.append(i + width)
			indices.append(i + 1)
			
			# Second triangle
			indices.append(i + 1)
			indices.append(i + width)
			indices.append(i + width + 1)
	
	# Calculate normals
	normals = calculate_normals(vertices, indices)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return array_mesh

func calculate_normals(vertices: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
	var normals = PackedVector3Array()
	normals.resize(vertices.size())
	
	# Initialize all normals to zero
	for i in range(normals.size()):
		normals[i] = Vector3.ZERO
	
	# Calculate face normals and accumulate vertex normals
	for i in range(0, indices.size(), 3):
		var i1 = indices[i]
		var i2 = indices[i + 1]
		var i3 = indices[i + 2]
		
		var v1 = vertices[i1]
		var v2 = vertices[i2]
		var v3 = vertices[i3]
		
		var face_normal = (v2 - v1).cross(v3 - v1).normalized()
		
		normals[i1] += face_normal
		normals[i2] += face_normal
		normals[i3] += face_normal
	
	# Normalize all vertex normals
	for i in range(normals.size()):
		normals[i] = normals[i].normalized()
	
	return normals

func create_collision_shape(mesh: ArrayMesh):
	# Create collision shape from mesh
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()
	terrain_body.add_child(collision_shape)

func apply_terrain_material():
	# Create a basic material for the terrain
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.7, 0.2)  # Green grass color
	material.roughness = 0.8
	material.metallic = 0.0
	terrain_mesh_instance.material_override = material

# Public methods for runtime terrain modification
func regenerate_terrain():
	if terrain_body:
		terrain_body.queue_free()
	generate_terrain()

func set_noise_seed(seed_value: int):
	noise.seed = seed_value
	regenerate_terrain()

func get_height_at_position(world_pos: Vector3) -> float:
	# Sample noise to get height at world position
	return noise.get_noise_2d(world_pos.x, world_pos.z) * height_scale
