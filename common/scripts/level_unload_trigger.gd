extends Area3D

## The level that will be unloaded when a node in the required group enters this trigger.
## Nothing will happen if the level isn't active in the scene tree.
@export_file("*.tscn") var level_path: String
## The node that enters this area needs to be in this group for the level to unlaod
@export var required_group: String = "player"


func _ready() -> void:
	# Connect body entered signal.
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	# Check if body is in group
	if body.is_in_group(required_group.to_lower()):
		# Unload level
		LevelManager.unload_level(level_path)
