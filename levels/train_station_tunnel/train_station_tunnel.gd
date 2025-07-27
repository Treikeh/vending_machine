extends Level3D


func _ready() -> void:
	#load_data(SaveManager.get_save_data(scene_file_path))
	pass


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"persistent_nodes": _save_persistent_nodes(),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_load_persistent_nodes(data.persistent_nodes)
