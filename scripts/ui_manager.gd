class_name UIManager
extends Control

# UI Manager - Handles all game UI elements

# UI Panel references
var inventory_panel: Control
var crafting_panel: Control
var interaction_panel: Control
var main_ui_container: Control

# System references
var inventory: Inventory
var crafting_manager: CraftingManager
var interaction_manager: InteractionManager

# UI state
var is_inventory_open: bool = false
var is_crafting_open: bool = false

# UI styling constants
const PANEL_COLOR = Color(0.2, 0.2, 0.3, 0.9)
const BUTTON_COLOR = Color(0.3, 0.3, 0.4)
const HIGHLIGHT_COLOR = Color(0.5, 0.7, 1.0)
const ERROR_COLOR = Color(1.0, 0.4, 0.4)
const SUCCESS_COLOR = Color(0.4, 1.0, 0.4)

# Signals
signal ui_state_changed(is_open: bool)

func _ready():
	print("UI Manager initialized")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Find system references
	call_deferred("connect_to_systems")
	
	# Create UI elements
	setup_ui()
	
	# Initially hide all panels
	hide_all_panels()

func connect_to_systems():
	# Find systems in scene tree
	inventory = get_tree().get_first_node_in_group("inventory")
	if not inventory:
		inventory = get_node_or_null("../PlayerInventory")
	
	crafting_manager = get_tree().get_first_node_in_group("crafting_manager")
	if not crafting_manager:
		crafting_manager = get_node_or_null("../CraftingManager")
	
	interaction_manager = get_tree().get_first_node_in_group("interaction_manager")
	if not interaction_manager:
		interaction_manager = get_node_or_null("../InteractionManager")
	
	# Connect signals
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		inventory.item_added.connect(_on_item_added)
		print("UI Manager connected to inventory")
	
	if crafting_manager:
		crafting_manager.crafting_started.connect(_on_crafting_started)
		crafting_manager.crafting_completed.connect(_on_crafting_completed)
		crafting_manager.crafting_failed.connect(_on_crafting_failed)
		print("UI Manager connected to crafting manager")
	
	if interaction_manager:
		interaction_manager.interaction_target_changed.connect(_on_interaction_target_changed)
		interaction_manager.interaction_started.connect(_on_interaction_started)
		interaction_manager.interaction_completed.connect(_on_interaction_completed)
		print("UI Manager connected to interaction manager")

func setup_ui():
	# Create main UI container
	main_ui_container = VBoxContainer.new()
	main_ui_container.name = "MainUIContainer"
	add_child(main_ui_container)
	
	# Create panels
	create_interaction_panel()
	create_inventory_panel()
	create_crafting_panel()
	
	print("UI setup complete")

func create_interaction_panel():
	# Small panel at top for interaction feedback
	interaction_panel = Panel.new()
	interaction_panel.name = "InteractionPanel"
	interaction_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	interaction_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	interaction_panel.custom_minimum_size = Vector2(300, 60)
	
	# Style the panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = PANEL_COLOR
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	interaction_panel.add_theme_stylebox_override("panel", style_box)
	
	# Add interaction label
	var interaction_label = Label.new()
	interaction_label.name = "InteractionLabel"
	interaction_label.text = "Press I for Inventory, C for Crafting"
	interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	interaction_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	interaction_label.add_theme_color_override("font_color", Color.WHITE)
	
	interaction_panel.add_child(interaction_label)
	main_ui_container.add_child(interaction_panel)

func create_inventory_panel():
	# Inventory panel - shows player items
	inventory_panel = Panel.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.custom_minimum_size = Vector2(400, 300)
	inventory_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	inventory_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inventory_panel.visible = false
	
	# Style the panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = PANEL_COLOR
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	inventory_panel.add_theme_stylebox_override("panel", style_box)
	
	# Create layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	
	# Title
	var title = Label.new()
	title.text = "INVENTORY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)
	
	# Inventory content area
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var inventory_content = VBoxContainer.new()
	inventory_content.name = "InventoryContent"
	scroll_container.add_child(inventory_content)
	vbox.add_child(scroll_container)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close (I)"
	close_button.pressed.connect(hide_inventory)
	vbox.add_child(close_button)
	
	inventory_panel.add_child(vbox)
	add_child(inventory_panel)

func create_crafting_panel():
	# Crafting panel - shows recipes and crafting interface
	crafting_panel = Panel.new()
	crafting_panel.name = "CraftingPanel"
	crafting_panel.custom_minimum_size = Vector2(600, 400)
	crafting_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	crafting_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	crafting_panel.visible = false
	
	# Style the panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = PANEL_COLOR
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	crafting_panel.add_theme_stylebox_override("panel", style_box)
	
	# Create layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	
	# Title
	var title = Label.new()
	title.text = "CRAFTING"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)
	
	# Split into recipes and inventory
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	
	# Available recipes section
	var recipes_section = VBoxContainer.new()
	recipes_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var recipes_label = Label.new()
	recipes_label.text = "Available Recipes"
	recipes_label.add_theme_color_override("font_color", Color.WHITE)
	recipes_section.add_child(recipes_label)
	
	var recipes_scroll = ScrollContainer.new()
	recipes_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var recipes_content = VBoxContainer.new()
	recipes_content.name = "RecipesContent"
	recipes_scroll.add_child(recipes_content)
	recipes_section.add_child(recipes_scroll)
	
	hbox.add_child(recipes_section)
	
	# Current inventory section
	var inventory_section = VBoxContainer.new()
	inventory_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var inventory_label = Label.new()
	inventory_label.text = "Your Materials"
	inventory_label.add_theme_color_override("font_color", Color.WHITE)
	inventory_section.add_child(inventory_label)
	
	var materials_scroll = ScrollContainer.new()
	materials_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var materials_content = VBoxContainer.new()
	materials_content.name = "MaterialsContent"
	materials_scroll.add_child(materials_content)
	inventory_section.add_child(materials_scroll)
	
	hbox.add_child(inventory_section)
	
	vbox.add_child(hbox)
	
	# Crafting status
	var status_label = Label.new()
	status_label.name = "CraftingStatus"
	status_label.text = "Ready to craft"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(status_label)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close (C)"
	close_button.pressed.connect(hide_crafting)
	vbox.add_child(close_button)
	
	crafting_panel.add_child(vbox)
	add_child(crafting_panel)

func _input(event):
	# Handle UI toggle inputs
	if event.is_action_pressed("ui_cancel"):  # Escape key - close all
		hide_all_panels()
	elif event.is_action_pressed("inventory"):  # I key
		toggle_inventory()
	elif event.is_action_pressed("crafting"):  # C key
		toggle_crafting()

func toggle_inventory():
	if is_inventory_open:
		hide_inventory()
	else:
		show_inventory()

func show_inventory():
	hide_all_panels()
	is_inventory_open = true
	inventory_panel.visible = true
	update_inventory_display()
	ui_state_changed.emit(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_inventory():
	is_inventory_open = false
	inventory_panel.visible = false
	ui_state_changed.emit(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_crafting():
	if is_crafting_open:
		hide_crafting()
	else:
		show_crafting()

func show_crafting():
	hide_all_panels()
	is_crafting_open = true
	crafting_panel.visible = true
	update_crafting_display()
	ui_state_changed.emit(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_crafting():
	is_crafting_open = false
	crafting_panel.visible = false
	ui_state_changed.emit(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func hide_all_panels():
	is_inventory_open = false
	is_crafting_open = false
	inventory_panel.visible = false
	crafting_panel.visible = false
	ui_state_changed.emit(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_inventory_display():
	if not inventory:
		return
	
	var content = inventory_panel.get_node("VBoxContainer/ScrollContainer/InventoryContent")
	
	# Clear existing content
	for child in content.get_children():
		child.queue_free()
	
	# Add inventory items
	var items = inventory.get_all_items()
	if items.size() == 0:
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		content.add_child(empty_label)
	else:
		for item_id in items:
			var quantity = items[item_id]
			var item_container = create_inventory_item_display(item_id, quantity)
			content.add_child(item_container)

func create_inventory_item_display(item_id: String, quantity: int) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	
	var name_label = Label.new()
	var display_name = item_id.capitalize()
	if crafting_manager and crafting_manager.has_item(item_id):
		var item = crafting_manager.get_item(item_id)
		display_name = item.display_name
	
	name_label.text = display_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override("font_color", Color.WHITE)
	
	var quantity_label = Label.new()
	quantity_label.text = "x" + str(quantity)
	quantity_label.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
	
	hbox.add_child(name_label)
	hbox.add_child(quantity_label)
	
	return hbox

func update_crafting_display():
	if not crafting_manager or not inventory:
		return
	
	update_recipes_display()
	update_materials_display()

func update_recipes_display():
	var content = crafting_panel.get_node("VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/RecipesContent")
	
	# Clear existing content
	for child in content.get_children():
		child.queue_free()
	
	# Add available recipes
	var recipes = crafting_manager.get_all_recipes()
	if recipes.size() == 0:
		var empty_label = Label.new()
		empty_label.text = "No recipes available"
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		content.add_child(empty_label)
	else:
		for recipe in recipes:
			var recipe_display = create_recipe_display(recipe)
			content.add_child(recipe_display)

func create_recipe_display(recipe: CraftingRecipe) -> Control:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	
	# Recipe title
	var title_label = Label.new()
	title_label.text = recipe.display_name
	title_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title_label)
	
	# Required materials
	var materials_label = Label.new()
	var materials_text = "Requires: "
	var material_parts = []
	for item_id in recipe.required_materials:
		var quantity = recipe.required_materials[item_id]
		material_parts.append(str(quantity) + "x " + item_id.capitalize())
	materials_text += ", ".join(material_parts)
	materials_label.text = materials_text
	materials_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	vbox.add_child(materials_label)
	
	# Output items
	var output_label = Label.new()
	var output_text = "Produces: "
	var output_parts = []
	for item_id in recipe.output_items:
		var quantity = recipe.output_items[item_id]
		output_parts.append(str(quantity) + "x " + item_id.capitalize())
	output_text += ", ".join(output_parts)
	output_label.text = output_text
	output_label.add_theme_color_override("font_color", SUCCESS_COLOR)
	vbox.add_child(output_label)
	
	# Craft button
	var craft_button = Button.new()
	var can_craft = inventory.can_craft_recipe(recipe.id)
	craft_button.text = "Craft" if can_craft else "Cannot Craft"
	craft_button.disabled = not can_craft
	if can_craft:
		craft_button.pressed.connect(_on_craft_button_pressed.bind(recipe.id))
	vbox.add_child(craft_button)
	
	# Separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	return vbox

func update_materials_display():
	var content = crafting_panel.get_node("VBoxContainer/HBoxContainer/VBoxContainer2/ScrollContainer/MaterialsContent")
	
	# Clear existing content
	for child in content.get_children():
		child.queue_free()
	
	# Add current materials
	var items = inventory.get_all_items()
	if items.size() == 0:
		var empty_label = Label.new()
		empty_label.text = "No materials"
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		content.add_child(empty_label)
	else:
		for item_id in items:
			var quantity = items[item_id]
			var item_display = create_inventory_item_display(item_id, quantity)
			content.add_child(item_display)

func _on_craft_button_pressed(recipe_id: String):
	if inventory and inventory.craft_item(recipe_id):
		print("Started crafting: ", recipe_id)
		update_crafting_status("Crafting in progress...")
	else:
		print("Failed to start crafting: ", recipe_id)
		update_crafting_status("Crafting failed!")

func update_crafting_status(status: String, color: Color = Color.WHITE):
	var status_label = crafting_panel.get_node("VBoxContainer/CraftingStatus")
	status_label.text = status
	status_label.add_theme_color_override("font_color", color)

func update_interaction_display(text: String, color: Color = Color.WHITE):
	var label = interaction_panel.get_node("InteractionLabel")
	label.text = text
	label.add_theme_color_override("font_color", color)

# Signal handlers
func _on_inventory_changed(item_id: String, new_quantity: int):
	if is_inventory_open:
		update_inventory_display()
	if is_crafting_open:
		update_materials_display()
		update_recipes_display()  # Update craft buttons

func _on_item_added(item_id: String, quantity: int):
	var display_name = item_id.capitalize()
	if crafting_manager and crafting_manager.has_item(item_id):
		var item = crafting_manager.get_item(item_id)
		display_name = item.display_name
	
	update_interaction_display("Added " + str(quantity) + "x " + display_name, SUCCESS_COLOR)
	
	# Auto-clear after 3 seconds
	await get_tree().create_timer(3.0).timeout
	update_interaction_display("Press I for Inventory, C for Crafting")

func _on_crafting_started(recipe: CraftingRecipe):
	update_crafting_status("Crafting " + recipe.display_name + "...", HIGHLIGHT_COLOR)

func _on_crafting_completed(recipe: CraftingRecipe, output_items: Dictionary):
	update_crafting_status("Completed: " + recipe.display_name, SUCCESS_COLOR)
	
	# Auto-clear after 3 seconds
	await get_tree().create_timer(3.0).timeout
	update_crafting_status("Ready to craft")

func _on_crafting_failed(recipe: CraftingRecipe, reason: String):
	var message = "Failed"
	if recipe:
		message += ": " + recipe.display_name
	update_crafting_status(message, ERROR_COLOR)
	
	# Auto-clear after 3 seconds
	await get_tree().create_timer(3.0).timeout
	update_crafting_status("Ready to craft")

func _on_interaction_target_changed(new_target: GatherableResource):
	if new_target:
		update_interaction_display("Press F to harvest " + new_target.resource_name, HIGHLIGHT_COLOR)
	else:
		update_interaction_display("Press I for Inventory, C for Crafting")

func _on_interaction_started(resource: GatherableResource):
	update_interaction_display("Harvesting " + resource.resource_name + "...", Color.ORANGE)

func _on_interaction_completed(resource: GatherableResource, items: Dictionary):
	var item_text = ""
	for item_id in items:
		var quantity = items[item_id]
		item_text += str(quantity) + "x " + item_id.capitalize() + " "
	
	update_interaction_display("Harvested " + item_text.strip_edges(), SUCCESS_COLOR)
	
	# Auto-clear after 3 seconds
	await get_tree().create_timer(3.0).timeout
	update_interaction_display("Press I for Inventory, C for Crafting")
