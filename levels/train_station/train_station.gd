extends Level3D


func _on_stop_train_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("train"):
		body.owner.stop()


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"persistent_nodes": SaveManager.save_persistent_nodes(self),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)
