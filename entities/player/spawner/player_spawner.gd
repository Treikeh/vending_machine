extends Node3D


@export var mesh: MeshInstance3D

var player_scene: String = "uid://b62jt4e6safbv"


func _ready() -> void:
	# Remove the mesh when the game starts
	mesh.hide()
	
	# Spawn player if there is no player in the scene
	if get_tree().get_first_node_in_group("player") == null:
		EventBus.load_level.emit(player_scene, global_transform)
