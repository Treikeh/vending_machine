extends Level3D


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"persistent_nodes": SaveManager.save_persistent_nodes(self),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)
