class_name CraftingRecipe
extends Resource

## Crafting recipe class defining required materials and output
## Supports multiple input materials and output items

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var crafting_time: float = 2.0
@export var required_crafting_station: String = "" # Empty means no station required
@export var unlock_level: int = 1

# Dictionary of item_id: quantity required
@export var required_materials: Dictionary = {}
# Dictionary of item_id: quantity produced
@export var output_items: Dictionary = {}

signal recipe_completed(recipe: CraftingRecipe)

func _init(recipe_id: String = "", name: String = ""):
	id = recipe_id
	display_name = name

func add_required_material(item_id: String, quantity: int) -> CraftingRecipe:
	required_materials[item_id] = quantity
	return self

func add_output_item(item_id: String, quantity: int) -> CraftingRecipe:
	output_items[item_id] = quantity
	return self

func set_crafting_station(station_id: String) -> CraftingRecipe:
	required_crafting_station = station_id
	return self

func set_crafting_time(time: float) -> CraftingRecipe:
	crafting_time = time
	return self

func is_valid() -> bool:
	return id != "" and display_name != "" and required_materials.size() > 0 and output_items.size() > 0

func get_required_material_count(item_id: String) -> int:
	return required_materials.get(item_id, 0)

func get_output_item_count(item_id: String) -> int:
	return output_items.get(item_id, 0)

func get_total_required_materials() -> int:
	var total = 0
	for quantity in required_materials.values():
		total += quantity
	return total

func get_total_output_items() -> int:
	var total = 0
	for quantity in output_items.values():
		total += quantity
	return total

func requires_crafting_station() -> bool:
	return required_crafting_station != ""

func get_recipe_info() -> String:
	var info = display_name
	if description != "":
		info += "\n" + description
	
	info += "\n\nRequired Materials:"
	for item_id in required_materials:
		info += "\n- " + item_id + ": " + str(required_materials[item_id])
	
	info += "\n\nProduces:"
	for item_id in output_items:
		info += "\n- " + item_id + ": " + str(output_items[item_id])
	
	if requires_crafting_station():
		info += "\n\nRequires: " + required_crafting_station
	
	info += "\nCrafting Time: " + str(crafting_time) + "s"
	
	return info
