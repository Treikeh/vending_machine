extends Node


@export var world_3d: Node3D
@export var gui: Control


func _ready() -> void:
	# Connect signals
	EventBus.start_loading_level.connect(_on_start_loading_level)
	
	loading_screen.hide()


func _process(_delta: float) -> void:
	if level_to_load != "" and can_spawn_level:	
		_check_level_loading_progress()


#region Level loading


@export_group("Level loading")
@export var loading_screen: LoadingScreen

var level_to_load: String = ""
var can_spawn_level: bool = false


func _on_start_loading_level(level_path: String) -> void:
	# Check if level exits
	if not ResourceLoader.exists(level_path):
		print("ERROR!: Level not found. Invalid level path")
		return
	
	# Start loading level
	#NOTE: I start to load the level before showing the loading screen to have it load the level ->
	# <- while the loading screen is fading inn
	level_to_load = level_path
	ResourceLoader.load_threaded_request(level_path)
	
	# Show loading screen
	loading_screen.fade_inn()
	# Only allow the level to be spawned when the loading screen is fully visible
	await loading_screen.fully_visible
	_unload_level()
	can_spawn_level = true


func _unload_level() -> void:
	for child: Node in world_3d.get_children():
		world_3d.remove_child(child)
		child.queue_free()


func _check_level_loading_progress() -> void:
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(level_to_load, progress)
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
			# Change level
			var new_level: PackedScene = ResourceLoader.load_threaded_get(level_to_load)
			world_3d.add_child(new_level.instantiate())
			# Finish loading level
			level_to_load = ""
			can_spawn_level = false
			# Hide loading screen
			loading_screen.fade_out()
			return

#endregion
