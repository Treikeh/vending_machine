extends Node3D


signal player_spawned


const PLAYER_SCENE: String = "uid://b62jt4e6safbv"

@onready var _mesh: MeshInstance3D = %Mesh


func _ready() -> void:
	# Remove the mesh when the game starts
	_mesh.hide()
	
	#TODO: Find a way to wait until after all loding has been completed
	await get_tree().create_timer(0.1).timeout
	
	# Spawn player if there is no player in the scene
	if get_tree().get_first_node_in_group("player") == null:
		LevelManager.load_level(PLAYER_SCENE, global_transform, _player_spawn_callback)
		print("Spawned player")


func _player_spawn_callback() -> void:
	player_spawned.emit()
