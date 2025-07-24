class_name Level3D
extends Area3D
@warning_ignore_start("unused_parameter")


func _exit_tree() -> void:
	SaveManager.add_save_data(scene_file_path, save_data())


func save_data() -> Dictionary:
	return {}


func with_data(data: Dictionary) -> Level3D:
	return self
