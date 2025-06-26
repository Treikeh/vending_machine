extends Node


@export var world_3d: Node3D
@export var gui: Control
@export var loading_screen: LoadingScreen


func _ready() -> void:
	# Connect signals
	EventBus.load_level.connect(_on_load_level)
	EventBus.unload_level.connect(_on_unload_level)


func _process(_delta: float) -> void:
	if can_spawn_levels:
		_check_level_loading_queue()


#region Level laoding


#NOTE: There might be a better name for this class
## Data that is useful to keep track of when loading scenes async
class LevelLoadingData:
	var path: String
	var transform: Transform3D

## Whether or not new levels are actually allowed to spawn into the scene tree
## Mainly used to stop levels from spawning inn when the loading screen is fading inn/out
var can_spawn_levels: bool = true
## A list of all the level that are currently loaded and active in the scene tree
## The key (String) is the resource path to the level
var loaded_levels: Dictionary[String, Node3D]
## A list of all the levels that are currently being loded in the background
var level_loading_queue: Array[LevelLoadingData] = []


## Start loading a new level. If a new trasform is given, the new level will be loaded asynchronously
func _on_load_level(level_path: String, transform: Transform3D = world_3d.global_transform) -> void:
	# Check if level exits
	if not ResourceLoader.exists(level_path):
		print("ERROR!: Level not found. Invalid level path")
		return
	
	# Check if level is already in the scene tree
	if loaded_levels.has(level_path):
		print("ERROR!: Level is already loaded")
		return
	
	# Stop levels from spawning/despawning wile the loading screen is fading inn
	if transform == world_3d.global_transform:
		# Stop levels from spawning while the loading screen is fading inn
		can_spawn_levels = false
		loading_screen.fade_inn()
		await loading_screen.fully_visible
		# Unload all levels and allow the new level to spawn when the loading screen is fully visible
		_unload_all_levels()
		can_spawn_levels = true
	
	# Setup loding queue data
	var level_data: LevelLoadingData = LevelLoadingData.new()
	level_data.path = level_path
	level_data.transform = transform
	
	# Add the level to the loading queue and start loading it
	level_loading_queue.append(level_data)
	ResourceLoader.load_threaded_request(level_path)


## Unload a specific level form the loaded_levels dict
func _on_unload_level(level_path: String) -> void:
	# Check if level is loaded
	if loaded_levels.has(level_path):
		# Remove level form scene
		var level: Node3D = loaded_levels[level_path]
		world_3d.remove_child(level)
		level.queue_free()
		# Remove level from loaded_levels dict
		loaded_levels.erase(level_path)


## Unload all child nodes of World3D.
## Only used when fully changing levels
func _unload_all_levels() -> void:
	for child: Node in world_3d.get_children():
		world_3d.remove_child(child)
		child.queue_free()


func _check_level_loading_queue() -> void:
	for level_data: LevelLoadingData in level_loading_queue:
		var progress: Array = []
		var status: int = ResourceLoader.load_threaded_get_status(level_data.path, progress)
		match status:
			0: ## THREAD_LOAD_INVALID_RESOURCE
				print("ERROR!: Invalid resource")
				return
			1: ## THREAD_LOAD_IN_PROGRESS
				loading_screen.update_progress(progress[0])
				return
			2: ## THREAD_LOAD_FAILED
				print("ERROR!: Level failed to load")
				return
			3: ## THREAD_LOAD_LOADED
				# Add level to World3D
				var new_level: Node3D = ResourceLoader.load_threaded_get(level_data.path).instantiate()
				world_3d.add_child(new_level)
				new_level.global_transform = level_data.transform
				
				# Add new level to loaded levels dict
				loaded_levels[level_data.path] = new_level
				
				# Remove level from loading queue
				level_loading_queue.erase(level_data)
				
				# Hide loading screen
				if loading_screen.visible:
					loading_screen.fade_out()
				return

#endregion
