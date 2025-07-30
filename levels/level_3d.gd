class_name Level3D
extends Node3D


@export var level_bounds: Area3D


func get_save_data() -> Dictionary:
	return {}


@warning_ignore("unused_parameter")
func load_save_data(data: Dictionary) -> void:
	pass
