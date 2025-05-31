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
	
	# Create crafting system
	create_crafting_system()
	
	# Create interaction system
	create_interaction_system()
	
	# Create UI system
	create_ui_system()
	
	# Create test resources
	create_test_resources()

func create_lighting():
	# Add directional light (sun)
	var sun_light = DirectionalLight3D.new()
	sun_light.name = "Sun"
	sun_light.position = Vector3(0, 10, 0)
	sun_light.rotation_degrees = Vector3(-45, 45, 0)
	sun_light.light_energy = 1.2
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	add_child(sun_light)
	
	# Add ambient fill light
	var ambient_light = DirectionalLight3D.new()
	ambient_light.name = "AmbientFill"
	ambient_light.rotation_degrees = Vector3(45, -45, 0)
	ambient_light.light_energy = 0.3
	ambient_light.light_color = Color(0.8, 0.9, 1.0)  # Slightly blue for sky bounce
	add_child(ambient_light)
	
	# Create enhanced environment
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	
	# Configure procedural sky
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.4, 0.6, 1.0)
	sky_material.sky_horizon_color = Color(0.8, 0.9, 1.0)
	sky_material.ground_bottom_color = Color(0.2, 0.3, 0.4)
	sky_material.ground_horizon_color = Color(0.6, 0.7, 0.8)
	sky_material.sun_angle_max = 45.0
	env.sky.sky_material = sky_material
	
	# Add ambient lighting
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.3
	
	# Add subtle fog for depth
	env.fog_enabled = true
	env.fog_light_color = Color(0.8, 0.9, 1.0)
	env.fog_light_energy = 0.5
	env.fog_density = 0.01
	
	get_viewport().environment = env

func create_terrain():
	# Create procedural terrain using TerrainGenerator
	var terrain_generator = preload("res://scripts/terrain_generator.gd").new()
	terrain_generator.name = "TerrainGenerator"
	add_child(terrain_generator)
	print("Procedural terrain system initialized")

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

func create_crafting_system():
	# Create crafting manager
	var crafting_manager = CraftingManager.new()
	crafting_manager.name = "CraftingManager"
	add_child(crafting_manager)
	
	# Create inventory system
	var inventory = Inventory.new()
	inventory.name = "PlayerInventory"
	inventory.set_max_slots(20)  # Limit to 20 different item types
	add_child(inventory)
	
	# Connect crafting signals for testing
	crafting_manager.crafting_started.connect(_on_crafting_started)
	crafting_manager.crafting_completed.connect(_on_crafting_completed)
	crafting_manager.crafting_failed.connect(_on_crafting_failed)
	
	# Connect inventory signals for testing
	inventory.inventory_changed.connect(_on_inventory_changed)
	inventory.item_added.connect(_on_item_added)
	inventory.inventory_full.connect(_on_inventory_full)
	
	# Add some starting materials for testing
	inventory.add_item("wood", 10)
	inventory.add_item("stone", 5)
	
	print("Crafting and inventory systems initialized")

func _input(event):
	# Handle crafting and inventory testing inputs
	if event.is_action_pressed("ui_accept"):  # Enter key
		test_crafting_system()
	if event.is_action_pressed("ui_cancel"):  # Escape key
		test_inventory_system()
	if event.is_action_pressed("ui_select"):  # Tab key
		test_interaction_system()
	
func test_crafting_system():
	# Test the crafting system with the real inventory
	var inventory = get_node("PlayerInventory")
	var crafting_manager = get_node("CraftingManager")
	
	if not inventory or not crafting_manager:
		print("Inventory or CraftingManager not found!")
		return
	
	print("\n--- CRAFTING SYSTEM TEST ---")
	inventory.debug_inventory()
	
	# Get all available recipes
	var all_recipes = crafting_manager.get_all_recipes()
	print("Total recipes available: ", all_recipes.size())
	
	# Check which recipes can be crafted with current inventory
	var craftable_recipes = []
	for recipe in all_recipes:
		if inventory.can_craft_recipe(recipe.id):
			craftable_recipes.append(recipe)
	
	print("Craftable recipes: ", craftable_recipes.size())
	for recipe in craftable_recipes:
		print("- Can craft: ", recipe.display_name)
	
	# Try to craft the first available recipe using inventory
	if craftable_recipes.size() > 0:
		var recipe_to_craft = craftable_recipes[0]
		print("\nAttempting to craft: ", recipe_to_craft.display_name)
		if inventory.craft_item(recipe_to_craft.id):
			print("Crafting started successfully!")
		else:
			print("Failed to start crafting")
	else:
		print("No craftable recipes with current inventory")
	
	print("\nPress Enter to craft, Escape to view inventory!")

func test_inventory_system():
	# Test inventory functionality
	var inventory = get_node("PlayerInventory")
	if not inventory:
		print("Inventory not found!")
		return
	
	print("\n--- INVENTORY SYSTEM TEST ---")
	inventory.debug_inventory()
	
	# Add some random materials for testing
	var test_items = ["wood", "stone"]
	var random_item = test_items[randi() % test_items.size()]
	var random_amount = randi_range(1, 3)
	
	print("\nAdding ", random_amount, "x ", random_item)
	inventory.add_item(random_item, random_amount)
	
	print("\nUpdated inventory:")
	inventory.debug_inventory()

func _on_crafting_started(recipe: CraftingRecipe):
	print("[CRAFTING] Started: ", recipe.display_name, " (Time: ", recipe.crafting_time, "s)")

func _on_crafting_completed(recipe: CraftingRecipe, output_items: Dictionary):
	print("[CRAFTING] Completed: ", recipe.display_name)
	print("[CRAFTING] Produced items: ", output_items)

func _on_crafting_failed(recipe: CraftingRecipe, reason: String):
	if recipe:
		print("[CRAFTING] Failed: ", recipe.display_name, " - ", reason)
	else:
		print("[CRAFTING] Failed: ", reason)

# Inventory signal handlers
func _on_inventory_changed(item_id: String, new_quantity: int):
	print("[INVENTORY] ", item_id, " quantity changed to: ", new_quantity)

func _on_item_added(item_id: String, quantity: int):
	print("[INVENTORY] Added ", quantity, "x ", item_id)

func _on_inventory_full():
	print("[INVENTORY] Inventory is full! Cannot add more item types.")

func create_interaction_system():
	# Create interaction manager
	var interaction_manager = InteractionManager.new()
	interaction_manager.name = "InteractionManager"
	add_child(interaction_manager)
	
	# Connect interaction signals for testing
	interaction_manager.interaction_target_changed.connect(_on_interaction_target_changed)
	interaction_manager.interaction_started.connect(_on_interaction_started)
	interaction_manager.interaction_completed.connect(_on_interaction_completed)
	interaction_manager.interaction_cancelled.connect(_on_interaction_cancelled)
	
	print("Interaction system initialized")

func create_ui_system():
	# Create UI manager
	var ui_manager = UIManager.new()
	ui_manager.name = "UIManager"
	add_child(ui_manager)
	
	# Connect UI state changes to camera controller
	var camera = get_node("FollowCamera")
	if camera:
		ui_manager.ui_state_changed.connect(camera._on_ui_state_changed)
	
	print("UI system initialized")

func create_test_resources():
	# Create test gatherable resources around the player spawn
	var terrain_generator = get_node("TerrainGenerator")
	
	# Create some trees
	for i in range(5):
		var angle = i * (TAU / 5.0)  # Distribute in a circle
		var radius = randf_range(8.0, 15.0)
		var pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		
		# Adjust height to terrain if available
		if terrain_generator and terrain_generator.has_method("get_height_at_position"):
			pos.y = terrain_generator.get_height_at_position(pos)
		else:
			pos.y = 1.0  # Default ground level
		
		var tree = GatherableResource.create_tree(pos)
		tree.name = "Tree_" + str(i)
		add_child(tree)
	
	# Create some rocks
	for i in range(3):
		var angle = (i * (TAU / 3.0)) + (TAU / 6.0)  # Offset from trees
		var radius = randf_range(6.0, 12.0)
		var pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		
		# Adjust height to terrain if available
		if terrain_generator and terrain_generator.has_method("get_height_at_position"):
			pos.y = terrain_generator.get_height_at_position(pos)
		else:
			pos.y = 1.0  # Default ground level
		
		var rock = GatherableResource.create_rock(pos)
		rock.name = "Rock_" + str(i)
		add_child(rock)
	
	print("Created test resources: 5 trees and 3 rocks")

# Interaction signal handlers
func _on_interaction_target_changed(new_target: GatherableResource):
	if new_target:
		print("[INTERACTION] Target: ", new_target.resource_name, " (", new_target.resource_id, ")")
	else:
		print("[INTERACTION] No target")

func _on_interaction_started(resource: GatherableResource):
	print("[INTERACTION] Started harvesting: ", resource.resource_name)

func _on_interaction_completed(resource: GatherableResource, items: Dictionary):
	print("[INTERACTION] Completed harvesting: ", resource.resource_name)
	if items.size() > 0:
		print("[INTERACTION] Items gained: ", items)

func _on_interaction_cancelled(resource: GatherableResource):
	print("[INTERACTION] Cancelled harvesting: ", resource.resource_name)

func test_interaction_system():
	# Test interaction system functionality
	var interaction_manager = get_node("InteractionManager")
	if not interaction_manager:
		print("InteractionManager not found!")
		return
	
	print("\n--- INTERACTION SYSTEM TEST ---")
	interaction_manager.debug_interactions()
	
	var info = interaction_manager.get_interaction_info()
	print("\nInteraction Info:")
	for key in info:
		print("  ", key, ": ", info[key])
	
	print("\nPress F to interact with highlighted resources!")
	print("Press Tab to debug interactions, Enter to craft, Escape for inventory!")
