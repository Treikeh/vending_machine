class_name MainScene
extends Node


@onready var _gui: Control = %GUI
@onready var _world_3d: Node3D = %World3D
@onready var _loading_screen: LoadingScreen = %LoadingScreen


func _ready() -> void:
	Globals.main = self


func _process(_delta: float) -> void:
	if _can_spawn_levels:
		_check_level_loading_queue()


#region Ui

func load_menu(menu_path: String) -> Control:
	# Check if scene exists
	if !ResourceLoader.exists(menu_path):
		print("ERROR!: Ui scene %s not found" % menu_path)
		return null
	
	# Load new scene and add it to the scene tree
	var new_scene: Control = load(menu_path).instantiate()
	_gui.add_child(new_scene)
	return new_scene


func unload_all_menus() -> void:
	for child: Node in _gui.get_children():
		_gui.remove_child(child)
		child.queue_free()

#endregion


#region Level laoding


#NOTE: There might be a better name for this class
## Data that is useful to keep track of when loading scenes async
class LevelLoadingData:
	var path: String
	var transform: Transform3D

## Whether or not new levels are actually allowed to spawn into the scene tree
## Mainly used to stop levels from spawning inn when the loading screen is fading inn/out
var _can_spawn_levels: bool = true
## A list of all the level that are currently loaded and active in the scene tree
## The key (String) is the uid or resource path (uid is prefered) to the level scene.
var _loaded_levels: Dictionary[String, Node3D]
## A list of all the levels that are currently being loded in the background
var _level_loading_queue: Array[LevelLoadingData] = []


## Start loading a new level. If a new trasform is given, the new level will be loaded asynchronously
#NOTE: The level path should be the "uid" of the scene
#NOTE: The the default transform is Transform3D.FLIP_Y because I can't assign null as the default value
func load_level(level_path: String, transform: Transform3D = Transform3D.FLIP_Y) -> void:
	# Check if level exits
	if not ResourceLoader.exists(level_path):
		print("ERROR!: Level %s not found. Invalid level path" % level_path)
		return
	
	# Check if level is already in the scene tree
	if _loaded_levels.has(level_path):
		print("NOTE!: Level %s is already loaded" % level_path)
		return
	
	# Setup loding queue data
	var level_data: LevelLoadingData = LevelLoadingData.new()
	level_data.path = level_path
	level_data.transform = transform
	
	# Check if a new transform was given.
	# If it was, show the loading screen and unload all currently active levels.
	if transform == Transform3D.FLIP_Y:
		# Stop levels from spawning/despawning wile the loading screen is fading inn
		_can_spawn_levels = false
		_loading_screen.fade_in()
		await _loading_screen.fully_visible
		# Unload all levels and allow the new level to spawn inn when the loading screen is fully visible
		_unload_all_levels()
		_can_spawn_levels = true
		# Override spawn transform
		level_data.transform = _world_3d.global_transform
	
	# Add the level to the loading queue and start loading it
	_level_loading_queue.append(level_data)
	ResourceLoader.load_threaded_request(level_path)


## Unload a specific level form the loaded_levels dict
func unload_level(level_path: String) -> void:
	# Check if level is loaded
	if _loaded_levels.has(level_path):
		# Remove level form scene
		var level: Node3D = _loaded_levels[level_path]
		_world_3d.remove_child(level)
		level.queue_free()
		# Remove level from loaded_levels dict
		_loaded_levels.erase(level_path)
	else:
		print("NOTE!: Level %s is not active in the scene tree" % level_path)


## Unload all child nodes of World3D.
## Only used when fully changing levels
func _unload_all_levels() -> void:
	for child: Node in _world_3d.get_children():
		_world_3d.remove_child(child)
		child.queue_free()
		_loaded_levels.clear()


func _check_level_loading_queue() -> void:
	for level_data: LevelLoadingData in _level_loading_queue:
		var progress: Array = []
		var status: int = ResourceLoader.load_threaded_get_status(level_data.path, progress)
		match status:
			0: ## THREAD_LOAD_INVALID_RESOURCE
				print("ERROR!: Invalid resource")
				return
			1: ## THREAD_LOAD_IN_PROGRESS
				_loading_screen.update_progress(progress[0])
				return
			2: ## THREAD_LOAD_FAILED
				print("ERROR!: Level failed to load")
				return
			3: ## THREAD_LOAD_LOADED
				# Add level to World3D
				var new_level: Node3D = ResourceLoader.load_threaded_get(level_data.path).instantiate()
				_world_3d.add_child(new_level)
				new_level.global_transform = level_data.transform
				
				# Add new level to loaded levels dict
				_loaded_levels[level_data.path] = new_level
				
				# Remove level from loading queue
				_level_loading_queue.erase(level_data)
				
				# Hide loading screen
				if _loading_screen.visible:
					_loading_screen.fade_out()
				return

#endregion
