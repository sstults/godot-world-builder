class_name CraftingManager
extends Node

## Central crafting system manager
## Handles recipe registration, validation, and crafting operations

signal crafting_started(recipe: CraftingRecipe)
signal crafting_completed(recipe: CraftingRecipe, output_items: Dictionary)
signal crafting_failed(recipe: CraftingRecipe, reason: String)
signal recipe_registered(recipe: CraftingRecipe)

# Registry of all available recipes
var recipes: Dictionary = {}
# Registry of all item definitions
var items: Dictionary = {}
# Currently active crafting operations
var active_crafting: Dictionary = {}

var next_crafting_id: int = 0

func _ready():
	add_to_group("crafting_manager")
	_initialize_base_items()
	_initialize_base_recipes()
	print("CraftingManager initialized with ", recipes.size(), " recipes and ", items.size(), " items")

func _initialize_base_items():
	"""Initialize basic item definitions for testing"""
	var wood = Item.new("wood", "Wood", "Basic building material from trees")
	wood.max_stack_size = 64
	wood.rarity = Item.ItemRarity.COMMON
	register_item(wood)
	
	var stone = Item.new("stone", "Stone", "Hard material for construction")
	stone.max_stack_size = 64
	stone.rarity = Item.ItemRarity.COMMON
	register_item(stone)
	
	var stick = Item.new("stick", "Stick", "Wooden stick for crafting")
	stick.max_stack_size = 64
	stick.rarity = Item.ItemRarity.COMMON
	register_item(stick)
	
	var wooden_pickaxe = Item.new("wooden_pickaxe", "Wooden Pickaxe", "Basic tool for mining")
	wooden_pickaxe.max_stack_size = 1
	wooden_pickaxe.rarity = Item.ItemRarity.COMMON
	register_item(wooden_pickaxe)

func _initialize_base_recipes():
	"""Initialize basic crafting recipes for testing"""
	# Stick recipe: 1 wood -> 4 sticks
	var stick_recipe = CraftingRecipe.new("recipe_stick", "Craft Sticks")
	stick_recipe.description = "Convert wood into useful sticks"
	stick_recipe.add_required_material("wood", 1)
	stick_recipe.add_output_item("stick", 4)
	stick_recipe.set_crafting_time(1.0)
	register_recipe(stick_recipe)
	
	# Wooden pickaxe recipe: 3 wood + 2 sticks -> 1 wooden pickaxe
	var pickaxe_recipe = CraftingRecipe.new("recipe_wooden_pickaxe", "Craft Wooden Pickaxe")
	pickaxe_recipe.description = "Craft a basic wooden pickaxe for mining"
	pickaxe_recipe.add_required_material("wood", 3)
	pickaxe_recipe.add_required_material("stick", 2)
	pickaxe_recipe.add_output_item("wooden_pickaxe", 1)
	pickaxe_recipe.set_crafting_time(3.0)
	register_recipe(pickaxe_recipe)

func register_item(item: Item) -> bool:
	"""Register a new item type"""
	if not item.is_valid():
		push_error("Cannot register invalid item: " + str(item.id))
		return false
	
	if items.has(item.id):
		push_warning("Item already registered: " + item.id)
		return false
	
	items[item.id] = item
	print("Registered item: ", item.id, " (", item.display_name, ")")
	return true

func register_recipe(recipe: CraftingRecipe) -> bool:
	"""Register a new crafting recipe"""
	if not recipe.is_valid():
		push_error("Cannot register invalid recipe: " + str(recipe.id))
		return false
	
	if recipes.has(recipe.id):
		push_warning("Recipe already registered: " + recipe.id)
		return false
	
	# Validate that all required materials exist
	for item_id in recipe.required_materials:
		if not items.has(item_id):
			push_error("Recipe " + recipe.id + " requires unknown item: " + item_id)
			return false
	
	# Validate that all output items exist
	for item_id in recipe.output_items:
		if not items.has(item_id):
			push_error("Recipe " + recipe.id + " produces unknown item: " + item_id)
			return false
	
	recipes[recipe.id] = recipe
	recipe_registered.emit(recipe)
	print("Registered recipe: ", recipe.id, " (", recipe.display_name, ")")
	return true

func get_item(item_id: String) -> Item:
	"""Get item definition by ID"""
	return items.get(item_id, null)

func get_recipe(recipe_id: String) -> CraftingRecipe:
	"""Get recipe by ID"""
	return recipes.get(recipe_id, null)

func get_all_recipes() -> Array[CraftingRecipe]:
	"""Get all registered recipes"""
	var recipe_list: Array[CraftingRecipe] = []
	for recipe in recipes.values():
		recipe_list.append(recipe)
	return recipe_list

func get_craftable_recipes(available_materials: Dictionary) -> Array[CraftingRecipe]:
	"""Get recipes that can be crafted with available materials"""
	var craftable: Array[CraftingRecipe] = []
	
	for recipe in recipes.values():
		if can_craft_recipe(recipe, available_materials):
			craftable.append(recipe)
	
	return craftable

func can_craft_recipe(recipe: CraftingRecipe, available_materials: Dictionary) -> bool:
	"""Check if a recipe can be crafted with available materials"""
	if not recipe or not recipe.is_valid():
		return false
	
	for item_id in recipe.required_materials:
		var required_amount = recipe.required_materials[item_id]
		var available_amount = available_materials.get(item_id, 0)
		
		if available_amount < required_amount:
			return false
	
	return true

func start_crafting(recipe_id: String, available_materials: Dictionary) -> int:
	"""Start a crafting operation, returns crafting_id or -1 if failed"""
	var recipe = get_recipe(recipe_id)
	
	if not recipe:
		push_error("Unknown recipe: " + recipe_id)
		crafting_failed.emit(null, "Unknown recipe: " + recipe_id)
		return -1
	
	if not can_craft_recipe(recipe, available_materials):
		var reason = "Insufficient materials for recipe: " + recipe_id
		push_warning(reason)
		crafting_failed.emit(recipe, reason)
		return -1
	
	var crafting_id = next_crafting_id
	next_crafting_id += 1
	
	var crafting_data = {
		"recipe": recipe,
		"start_time": Time.get_time_dict_from_system(),
		"crafting_time": recipe.crafting_time,
		"progress": 0.0
	}
	
	active_crafting[crafting_id] = crafting_data
	
	crafting_started.emit(recipe)
	print("Started crafting: ", recipe.display_name, " (ID: ", crafting_id, ")")
	
	# Start the crafting timer
	var timer = Timer.new()
	timer.wait_time = recipe.crafting_time
	timer.one_shot = true
	timer.timeout.connect(_on_crafting_completed.bind(crafting_id))
	add_child(timer)
	timer.start()
	
	return crafting_id

func _on_crafting_completed(crafting_id: int):
	"""Handle completion of a crafting operation"""
	if not active_crafting.has(crafting_id):
		push_error("Crafting operation not found: " + str(crafting_id))
		return
	
	var crafting_data = active_crafting[crafting_id]
	var recipe = crafting_data["recipe"]
	
	# Remove the crafting operation from active list
	active_crafting.erase(crafting_id)
	
	# Emit completion signal with output items
	crafting_completed.emit(recipe, recipe.output_items)
	print("Completed crafting: ", recipe.display_name)

func get_crafting_progress(crafting_id: int) -> float:
	"""Get progress of an active crafting operation (0.0 to 1.0)"""
	if not active_crafting.has(crafting_id):
		return 0.0
	
	var crafting_data = active_crafting[crafting_id]
	var elapsed_time = Time.get_time_dict_from_system()["unix"] - crafting_data["start_time"]["unix"]
	var progress = min(elapsed_time / crafting_data["crafting_time"], 1.0)
	
	return progress

func cancel_crafting(crafting_id: int) -> bool:
	"""Cancel an active crafting operation"""
	if not active_crafting.has(crafting_id):
		return false
	
	var crafting_data = active_crafting[crafting_id]
	var recipe = crafting_data["recipe"]
	
	active_crafting.erase(crafting_id)
	
	# Find and remove the timer
	for child in get_children():
		if child is Timer:
			child.queue_free()
			break
	
	print("Cancelled crafting: ", recipe.display_name)
	return true

func get_active_crafting_count() -> int:
	"""Get number of currently active crafting operations"""
	return active_crafting.size()

func is_crafting_active(crafting_id: int) -> bool:
	"""Check if a crafting operation is still active"""
	return active_crafting.has(crafting_id)
