extends Level3D

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
