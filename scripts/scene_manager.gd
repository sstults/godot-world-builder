extends Node
class_name SceneManager

# Scene management singleton

signal scene_loading_started(scene_name: String)
signal scene_loading_finished(scene_name: String)
signal scene_loading_failed(scene_name: String, error: String)

# Scene registry - maps scene names to file paths
var scene_registry = {
	"main": "res://scenes/main.tscn",
	"menu": "res://scenes/menu.tscn",
	"world": "res://scenes/world.tscn"
}

var current_scene: Node = null
var loading_thread: Thread
var loading_mutex: Mutex
var loading_semaphore: Semaphore

func _ready():
	# Initialize threading components for async loading
	loading_mutex = Mutex.new()
	loading_semaphore = Semaphore.new()
	
	# Set current scene to the main scene tree's current scene
	var tree = get_tree()
	current_scene = tree.current_scene

func _exit_tree():
	# Clean up threading resources
	if loading_thread and loading_thread.is_alive():
		loading_thread.wait_to_finish()

# Load scene by name from registry
func load_scene(scene_name: String, use_async: bool = false) -> bool:
	if not scene_registry.has(scene_name):
		push_error("Scene not found in registry: " + scene_name)
		scene_loading_failed.emit(scene_name, "Scene not found in registry")
		return false
	
	var scene_path = scene_registry[scene_name]
	return load_scene_from_path(scene_path, use_async)

# Load scene from direct path
func load_scene_from_path(scene_path: String, use_async: bool = false) -> bool:
	if not ResourceLoader.exists(scene_path):
		push_error("Scene file not found: " + scene_path)
		scene_loading_failed.emit(scene_path, "Scene file not found")
		return false
	
	scene_loading_started.emit(scene_path)
	
	if use_async:
		return load_scene_async(scene_path)
	else:
		return load_scene_sync(scene_path)

# Synchronous scene loading
func load_scene_sync(scene_path: String) -> bool:
	var new_scene = load(scene_path)
	if not new_scene:
		push_error("Failed to load scene: " + scene_path)
		scene_loading_failed.emit(scene_path, "Failed to load scene resource")
		return false
	
	return change_scene_to_packed(new_scene, scene_path)

# Asynchronous scene loading
func load_scene_async(scene_path: String) -> bool:
	if loading_thread and loading_thread.is_alive():
		push_warning("Scene loading already in progress")
		return false
	
	loading_thread = Thread.new()
	loading_thread.start(_async_load_worker.bind(scene_path))
	return true

# Async loading worker function
func _async_load_worker(scene_path: String):
	loading_mutex.lock()
	
	var new_scene = load(scene_path)
	
	# Use call_deferred to switch to main thread for scene change
	call_deferred("_complete_async_load", new_scene, scene_path)
	
	loading_mutex.unlock()

# Complete async loading on main thread
func _complete_async_load(new_scene: PackedScene, scene_path: String):
	if loading_thread and loading_thread.is_alive():
		loading_thread.wait_to_finish()
	
	if not new_scene:
		scene_loading_failed.emit(scene_path, "Failed to load scene resource")
		return
	
	change_scene_to_packed(new_scene, scene_path)

# Change to a packed scene
func change_scene_to_packed(packed_scene: PackedScene, scene_path: String) -> bool:
	var new_scene_instance = packed_scene.instantiate()
	if not new_scene_instance:
		push_error("Failed to instantiate scene: " + scene_path)
		scene_loading_failed.emit(scene_path, "Failed to instantiate scene")
		return false
	
	# Free current scene and replace it
	var tree = get_tree()
	if current_scene:
		current_scene.queue_free()
	
	current_scene = new_scene_instance
	tree.root.add_child(new_scene_instance)
	tree.current_scene = new_scene_instance
	
	scene_loading_finished.emit(scene_path)
	print("Scene loaded successfully: ", scene_path)
	return true

# Register a new scene in the registry
func register_scene(scene_name: String, scene_path: String):
	scene_registry[scene_name] = scene_path
	print("Registered scene: ", scene_name, " -> ", scene_path)

# Unregister a scene from the registry
func unregister_scene(scene_name: String):
	if scene_registry.has(scene_name):
		scene_registry.erase(scene_name)
		print("Unregistered scene: ", scene_name)

# Get list of all registered scenes
func get_registered_scenes() -> Array:
	return scene_registry.keys()

# Check if a scene is registered
func is_scene_registered(scene_name: String) -> bool:
	return scene_registry.has(scene_name)

# Reload current scene
func reload_current_scene():
	var current_scene_path = current_scene.scene_file_path
	if current_scene_path:
		load_scene_from_path(current_scene_path)
	else:
		push_error("Current scene has no file path")

# Preload scenes for faster switching
var preloaded_scenes = {}

func preload_scene(scene_name: String) -> bool:
	if not scene_registry.has(scene_name):
		push_error("Scene not found in registry: " + scene_name)
		return false
	
	var scene_path = scene_registry[scene_name]
	var packed_scene = load(scene_path)
	
	if packed_scene:
		preloaded_scenes[scene_name] = packed_scene
		print("Preloaded scene: ", scene_name)
		return true
	else:
		push_error("Failed to preload scene: ", scene_name)
		return false

# Load from preloaded scene
func load_preloaded_scene(scene_name: String) -> bool:
	if not preloaded_scenes.has(scene_name):
		push_warning("Scene not preloaded: " + scene_name)
		return load_scene(scene_name)  # Fall back to normal loading
	
	var packed_scene = preloaded_scenes[scene_name]
	return change_scene_to_packed(packed_scene, scene_name)

# Clear preloaded scenes to free memory
func clear_preloaded_scenes():
	preloaded_scenes.clear()
	print("Cleared all preloaded scenes")

# Get current scene name
func get_current_scene_name() -> String:
	for scene_name in scene_registry:
		if scene_registry[scene_name] == current_scene.scene_file_path:
			return scene_name
	return "unknown"
