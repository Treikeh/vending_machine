class_name MainScene
extends Node


# The reason I use @export here and not @onready is because I need the references to be avalible
# before the _ready function is called in child nodes. And since every node (except for autoloads)
# will be a children of this node, there might be a situation where they try to acces the reference
# before it's set.
@export var _gui: Control
@export var _world_3d: Node3D

@onready var _loading_screen: LoadingScreen = %LoadingScreen


func _init() -> void:
	# I'm setting the reference here and not in _ready because child nodes might need to use the reference
	# in their own _ready functions, and since child nodes call thier _ready functions before the parent
	# there might be a situation where they try to acces the reference before it's set.
	#NOTE: It's only necessary to do this when testing levels. When shipping the game, the splash screen
	# will be the frist and only scene that is loaded and it doesn't need a reference to the main scene.
	# So setting the reference in _ready would then work.
	Globals.main = self


func _process(_delta: float) -> void:
	if _can_spawn_levels:
		_check_level_loading_queue()


## This function reparents a node to become a child of world_3d.
## Can be used to discconet an object form the level it spawned into.
func attach_to_world_3d(node: Node, use_global_transform: bool = true) -> void:
	node.reparent(_world_3d, use_global_transform)


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

## Whether or not new levels are actually allowed to spawn into the scene tree
## Mainly used to stop levels from spawning in when the loading screen is fading in/out
var _can_spawn_levels: bool = true
## A list of all the level that are currently loaded and active in the scene tree
## The key (String) is the UID or resource path (I prefer UID) to the level scene.
var _loaded_levels: Dictionary[String, Node3D]
## A list of all the levels that are currently being loded in the background
var _level_loading_queue: Array[LevelLoadingData] = []


## Start loading a new level. If a new trasform is given, the new level will be loaded additively
#NOTE: The level path should be the UID or of the scene
#NOTE: The the default transform is Transform3D.FLIP_Y because I can't assign null as the default value
func load_level(
		level_path: String,
		spawn_transform: Transform3D = Transform3D.FLIP_Y,
		spawn_callback: Callable = func():,
) -> void:
	# Check if level exits
	if not ResourceLoader.exists(level_path):
		print("ERROR!: Level %s not found. Invalid level path" % level_path)
		return
	
	# Check if level is already in the scene tree
	if _loaded_levels.has(level_path):
		print("NOTE!: Level %s is already loaded" % level_path)
		return
	
	# Setup loding queue data
	var level_data := LevelLoadingData.new(level_path, spawn_transform, spawn_callback)
	
	# Check if a new transform was given.
	# If it was, show the loading screen and unload all currently active levels.
	if spawn_transform == Transform3D.FLIP_Y:
		# Stop levels from spawning/despawning wile the loading screen is fading inn
		_can_spawn_levels = false
		_loading_screen.fade_in()
		await _loading_screen.fully_visible
		# Unload all levels and allow the new level to spawn inn when the loading screen is fully visible
		_unload_all_levels()
		_can_spawn_levels = true
		# Override spawn transform
		level_data.spawn_transform = _world_3d.global_transform
	
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
		var status: int = ResourceLoader.load_threaded_get_status(level_data.level_path, progress)
		match status:
			0: ## THREAD_LOAD_INVALID_RESOURCE
				print("ERROR!: Invalid resource")
				continue
			1: ## THREAD_LOAD_IN_PROGRESS
				_loading_screen.update_progress(progress[0])
				continue
			2: ## THREAD_LOAD_FAILED
				print("ERROR!: Level failed to load")
				continue
			3: ## THREAD_LOAD_LOADED
				_add_level_to_world_3d(level_data)
				continue


func _add_level_to_world_3d(level_data: LevelLoadingData) -> void:
	# Spawn level into the scene
	var new_level: Node3D = ResourceLoader.load_threaded_get(level_data.level_path).instantiate()
	_world_3d.add_child(new_level)
	new_level.global_transform = level_data.spawn_transform
	
	# Call spawn_callback at the end of the frame
	level_data.spawn_callback.call_deferred()
	
	# Add new level to loaded levels dict
	_loaded_levels[level_data.level_path] = new_level
	
	# Remove level from loading queue
	_level_loading_queue.erase(level_data)
	
	# Hide the loading screen if it's visible
	if _loading_screen.visible:
		_loading_screen.fade_out()


## Data that is needed when loading the levels
class LevelLoadingData:
	# Path to the level (Necessary). Used to check the loading status of the level.
	var level_path: String
	# Where the level will spawn (Optional).
	# If set, the new level will be spawned in additively with the other levels.
	# If not set, all the active levels will be unloaded before spawning in the new level.
	var spawn_transform: Transform3D
	# A function that will be called when the new level has been added to the scene tree (Optional).
	# Used when you want to delay a function unitl the desired level has been spawned.
	var spawn_callback: Callable
	
	func _init(path: String, transform: Transform3D, callback: Callable) -> void:
		level_path = path
		spawn_transform = transform
		spawn_callback = callback

#endregion
