class_name Inventory
extends Node

## Player inventory system for item management
## Handles item storage, stacking, and integration with crafting system

signal inventory_changed(item_id: String, new_quantity: int)
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_stack_full(item_id: String)
signal inventory_full()

# Dictionary of item_id: quantity
var items: Dictionary = {}
# Maximum number of different item types (0 = unlimited)
var max_slots: int = 0
# Reference to crafting manager for item validation
var crafting_manager: CraftingManager

func _ready():
	add_to_group("inventory")
	_find_crafting_manager()

func _find_crafting_manager():
	"""Find and store reference to CraftingManager"""
	var managers = get_tree().get_nodes_in_group("crafting_manager")
	if managers.size() > 0:
		crafting_manager = managers[0]
		print("Inventory connected to CraftingManager")
	else:
		push_warning("CraftingManager not found - inventory will have limited functionality")

func set_max_slots(slots: int):
	"""Set maximum inventory slots (0 = unlimited)"""
	max_slots = slots
	print("Inventory max slots set to: ", max_slots if max_slots > 0 else "unlimited")

func get_item_count(item_id: String) -> int:
	"""Get quantity of a specific item"""
	return items.get(item_id, 0)

func get_all_items() -> Dictionary:
	"""Get copy of all items in inventory"""
	return items.duplicate()

func get_unique_item_count() -> int:
	"""Get number of different item types in inventory"""
	return items.size()

func has_item(item_id: String, quantity: int = 1) -> bool:
	"""Check if inventory contains at least the specified quantity of an item"""
	return get_item_count(item_id) >= quantity

func has_items(required_items: Dictionary) -> bool:
	"""Check if inventory contains all required items with quantities"""
	for item_id in required_items:
		var required_quantity = required_items[item_id]
		if not has_item(item_id, required_quantity):
			return false
	return true

func can_add_item(item_id: String, quantity: int = 1) -> bool:
	"""Check if item can be added to inventory"""
	if not crafting_manager:
		push_warning("Cannot validate item without CraftingManager")
		return false
	
	var item = crafting_manager.get_item(item_id)
	if not item:
		push_warning("Unknown item: " + item_id)
		return false
	
	# Check slot limit
	if max_slots > 0 and not items.has(item_id) and items.size() >= max_slots:
		return false
	
	# Check stack limit
	var current_quantity = get_item_count(item_id)
	var max_stack = item.max_stack_size
	
	return current_quantity + quantity <= max_stack

func add_item(item_id: String, quantity: int = 1) -> bool:
	"""Add items to inventory, returns true if successful"""
	if quantity <= 0:
		push_warning("Cannot add non-positive quantity: " + str(quantity))
		return false
	
	if not can_add_item(item_id, quantity):
		# Check specific reason for failure
		if max_slots > 0 and not items.has(item_id) and items.size() >= max_slots:
			inventory_full.emit()
			print("Inventory full - cannot add new item type: ", item_id)
		else:
			item_stack_full.emit(item_id)
			print("Item stack full - cannot add more: ", item_id)
		return false
	
	var previous_quantity = get_item_count(item_id)
	items[item_id] = previous_quantity + quantity
	
	item_added.emit(item_id, quantity)
	inventory_changed.emit(item_id, items[item_id])
	
	print("Added to inventory: ", quantity, "x ", item_id, " (Total: ", items[item_id], ")")
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""Remove items from inventory, returns true if successful"""
	if quantity <= 0:
		push_warning("Cannot remove non-positive quantity: " + str(quantity))
		return false
	
	if not has_item(item_id, quantity):
		print("Insufficient items to remove: ", item_id, " (Have: ", get_item_count(item_id), ", Need: ", quantity, ")")
		return false
	
	var current_quantity = items[item_id]
	var new_quantity = current_quantity - quantity
	
	if new_quantity <= 0:
		items.erase(item_id)
		new_quantity = 0
	else:
		items[item_id] = new_quantity
	
	item_removed.emit(item_id, quantity)
	inventory_changed.emit(item_id, new_quantity)
	
	print("Removed from inventory: ", quantity, "x ", item_id, " (Remaining: ", new_quantity, ")")
	return true

func remove_items(items_to_remove: Dictionary) -> bool:
	"""Remove multiple items from inventory, returns true if successful"""
	# First check if we have all required items
	if not has_items(items_to_remove):
		print("Cannot remove items - insufficient quantities")
		return false
	
	# Remove all items
	var success = true
	for item_id in items_to_remove:
		var quantity = items_to_remove[item_id]
		if not remove_item(item_id, quantity):
			success = false
			push_error("Failed to remove item during batch removal: " + item_id)
	
	return success

func clear_inventory():
	"""Remove all items from inventory"""
	var old_items = items.duplicate()
	items.clear()
	
	for item_id in old_items:
		inventory_changed.emit(item_id, 0)
	
	print("Inventory cleared")

func get_inventory_value() -> int:
	"""Get total item count across all stacks"""
	var total = 0
	for quantity in items.values():
		total += quantity
	return total

func get_item_info(item_id: String) -> String:
	"""Get formatted info about an item in inventory"""
	if not has_item(item_id):
		return "Not in inventory: " + item_id
	
	var quantity = get_item_count(item_id)
	var info = str(quantity) + "x " + item_id
	
	if crafting_manager:
		var item = crafting_manager.get_item(item_id)
		if item:
			info = str(quantity) + "x " + item.display_name
			if item.max_stack_size > 1:
				info += " (" + str(quantity) + "/" + str(item.max_stack_size) + ")"
	
	return info

func get_inventory_summary() -> String:
	"""Get formatted summary of entire inventory"""
	if items.is_empty():
		return "Inventory is empty"
	
	var summary = "Inventory (" + str(get_unique_item_count()) + " types, " + str(get_inventory_value()) + " total items):\n"
	
	var sorted_items = items.keys()
	sorted_items.sort()
	
	for item_id in sorted_items:
		summary += "- " + get_item_info(item_id) + "\n"
	
	return summary.strip_edges()

func can_craft_recipe(recipe_id: String) -> bool:
	"""Check if inventory has materials to craft a recipe"""
	if not crafting_manager:
		return false
	
	var recipe = crafting_manager.get_recipe(recipe_id)
	if not recipe:
		return false
	
	return has_items(recipe.required_materials)

func craft_item(recipe_id: String) -> bool:
	"""Attempt to craft an item using inventory materials"""
	if not crafting_manager:
		push_error("Cannot craft without CraftingManager")
		return false
	
	var recipe = crafting_manager.get_recipe(recipe_id)
	if not recipe:
		push_error("Unknown recipe: " + recipe_id)
		return false
	
	if not can_craft_recipe(recipe_id):
		print("Cannot craft - insufficient materials for: ", recipe.display_name)
		return false
	
	# Start crafting operation
	var crafting_id = crafting_manager.start_crafting(recipe_id, get_all_items())
	
	if crafting_id >= 0:
		# Remove materials from inventory
		if remove_items(recipe.required_materials):
			print("Started crafting: ", recipe.display_name, " (ID: ", crafting_id, ")")
			
			# Connect to completion signal to add output items
			if not crafting_manager.crafting_completed.is_connected(_on_crafting_completed):
				crafting_manager.crafting_completed.connect(_on_crafting_completed)
			
			return true
		else:
			# If material removal failed, cancel crafting
			crafting_manager.cancel_crafting(crafting_id)
			push_error("Failed to remove materials for crafting")
			return false
	else:
		print("Failed to start crafting: ", recipe.display_name)
		return false

func _on_crafting_completed(recipe: CraftingRecipe, output_items: Dictionary):
	"""Handle completion of crafting operation"""
	print("Crafting completed: ", recipe.display_name)
	
	# Add output items to inventory
	for item_id in output_items:
		var quantity = output_items[item_id]
		add_item(item_id, quantity)

func debug_inventory():
	"""Print detailed inventory information"""
	print("\n--- INVENTORY DEBUG ---")
	print(get_inventory_summary())
	if max_slots > 0:
		print("Slots used: ", get_unique_item_count(), "/", max_slots)
	print("Total item count: ", get_inventory_value())
	print("------------------------")
