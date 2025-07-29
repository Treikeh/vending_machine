extends Resource
class_name LevelLoadingData
## Data that is needed when loading the levels


# Path to the level (Necessary). Used to check the loading status of the level.
var level_path: String
# Where the level will spawn (Optional).
# If set, the new level will be spawned in additively with the other levels.
# If not set, all the active levels will be unloaded before spawning in the new level.
var spawn_transform: Transform3D
# A function that will be called when the new level has been added to the scene tree (Optional).
# Used when you want to delay a function unitl the desired level has been spawned.
var spawn_callback: Callable


func _init(path: String, transfrom: Transform3D, callback: Callable) -> void:
	level_path = path
	spawn_transform = transfrom
	spawn_callback = callback
