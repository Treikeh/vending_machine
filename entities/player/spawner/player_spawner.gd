extends Node3D


const PLAYER_SCENE: String = "uid://b62jt4e6safbv"
const HUD_SCENE: String = "uid://codyyu2jnkho5"

@onready var _mesh: MeshInstance3D = %Mesh


func _ready() -> void:
	# Remove the mesh when the game starts
	_mesh.hide()
	
	# Spawn player if there is no player in the scene
	if get_tree().get_first_node_in_group("player") == null:
		Globals.main.load_level(PLAYER_SCENE, global_transform)
		Globals.main.load_menu(HUD_SCENE)
