extends Area3D


## The new level that will be spawned when a node in the required group enters this trigger.
## Nothing will happen if the level is already loaded and active in the scene tree.
@export_file("*.tscn") var level_path: String
## The node that enters this area needs to be in this group for the level to start loading.
@export var required_group: String = "player"
## Where the new level will spawn.
## If set, the new level will be added to the world along with all other currently active levels.
## If left empty, all currently active levels will be unloaded and replaced with the new level.
@export var spawn_transform: Node3D


func _ready() -> void:
	# Connect body entered signal.
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	# Check if body is in group
	if body.is_in_group(required_group.to_lower()):
		# Is spawn transform is specified, load the level additively. If not, change the level
		if spawn_transform != null:
			Globals.main.load_level(level_path, spawn_transform.global_transform)
		else:
			Globals.main.load_level(level_path)
