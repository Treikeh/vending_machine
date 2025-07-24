extends BaseItem


func save_data() -> Dictionary:
	var data: Dictionary = {
		"transform": var_to_str(transform),
		"linear_velocity": var_to_str(linear_velocity),
		"angular_velocity": var_to_str(angular_velocity)
	}
	return data


func with_data(data: Dictionary) -> BaseItem:
	if not data.is_empty():
		transform = str_to_var(data.transform)
		linear_velocity = str_to_var(data.linear_velocity)
		angular_velocity = str_to_var(data.angular_velocity)
	return self
