extends BaseItem


@export var normal_mesh: Node3D
@export var empty_mesh: Node3D

var empty: bool = false


func _ready() -> void:
	if not empty:
		empty_mesh.hide()


func _item_used(instigator: Node3D) -> void:
	if !empty:
		empty = true
		empty_mesh.show()
		normal_mesh.hide()
		# Launch player upwards when drinking the can
		if instigator is RigidBody3D:
			instigator.apply_central_impulse(Vector3.UP * 10.0)


func save_data() -> Dictionary:
	var data: Dictionary = {
		"used": empty_mesh.visible,
		"transform": var_to_str(transform),
		"linear_velocity": var_to_str(linear_velocity),
		"angular_velocity": var_to_str(angular_velocity),
	}
	return data


func with_data(data: Dictionary) -> BaseItem:
	if not data.is_empty():
		if data.used:
			empty = data.used
			normal_mesh.hide()
			empty_mesh.show()
		transform = str_to_var(data.transform)
		linear_velocity = str_to_var(data.linear_velocity)
		angular_velocity = str_to_var(data.angular_velocity)
	return self
