extends BaseItem


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"linear_velocity": var_to_str(linear_velocity),
		"angular_velocity": var_to_str(angular_velocity)
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		linear_velocity = str_to_var(data.linear_velocity)
		angular_velocity = str_to_var(data.angular_velocity)
