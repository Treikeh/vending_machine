extends Level3D


const TRAIN_SCENE: String = "uid://puva7m3d5vds"

@export var _train_spawn_point_left: Marker3D
@export var _train_spawn_point_right: Marker3D


func _spawn_train() -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player")
	if get_tree().get_first_node_in_group("train") == null:
		var player_local_x_pos: float = to_local(player.global_position).x
		var spawn_point: Marker3D = _train_spawn_point_left if player_local_x_pos >= 0.0 else _train_spawn_point_right
		LevelManager.load_level(TRAIN_SCENE, spawn_point.global_transform)


func _on_stop_train_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("train"):
		body.stop()


func get_save_data() -> Dictionary:
	var overlapping_nodes: Array[Node3D] = Utility.get_overlapping_nodes(level_bounds)
	var data: Dictionary = {
		"persistent_nodes": SaveManager.save_persistent_nodes(self, overlapping_nodes),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)
