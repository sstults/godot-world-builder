class_name Item
extends Resource

## Basic item class for the crafting system
## Represents a single item type with properties and metadata

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var max_stack_size: int = 64
@export var is_craftable: bool = true
@export var rarity: ItemRarity = ItemRarity.COMMON
@export var icon_path: String = ""
@export var mesh_path: String = ""

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

func _init(item_id: String = "", name: String = "", desc: String = ""):
	id = item_id
	display_name = name
	description = desc

func get_rarity_color() -> Color:
	match rarity:
		ItemRarity.COMMON:
			return Color.WHITE
		ItemRarity.UNCOMMON:
			return Color.GREEN
		ItemRarity.RARE:
			return Color.BLUE
		ItemRarity.EPIC:
			return Color.PURPLE
		ItemRarity.LEGENDARY:
			return Color.ORANGE
		_:
			return Color.WHITE

func is_valid() -> bool:
	return id != "" and display_name != ""

func get_info_text() -> String:
	var info = display_name
	if description != "":
		info += "\n" + description
	info += "\nRarity: " + ItemRarity.keys()[rarity]
	info += "\nMax Stack: " + str(max_stack_size)
	return info
