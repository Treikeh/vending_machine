extends InteractArea3D


## How long time it takes for the door to open/close
@export var _open_speed: float = 0.5
## How much the door will rotate when opening
@export var _open_rotation := Vector3(0.0, 90.0, 0.0)
## How much the door will move when opening
@export var _open_position := Vector3(0.0, 0.0, 0.0)
@export var _ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var _transition_type: Tween.TransitionType = Tween.TRANS_LINEAR

var _is_open: bool = false
var _start_transform: Transform3D
var _open_transform: Transform3D


func _ready() -> void:
	_start_transform = transform
	_open_transform = _get_open_transform()
	if _is_open:
		transform = _open_transform


func _on_interacted(_instigator: Node3D) -> void:
	if _is_open:
		_is_open = false
		var tween: Tween = create_tween()
		tween.set_ease(_ease_type)
		tween.set_trans(_transition_type)
		tween.tween_property(self, "transform", _start_transform, _open_speed)
	else:
		_is_open = true
		var tween: Tween = create_tween()
		tween.set_ease(_ease_type)
		tween.set_trans(_transition_type)
		tween.tween_property(self, "transform", _open_transform, _open_speed)


func _get_open_transform() -> Transform3D:
	var open_quat := Quaternion.from_euler(Utility.vec3_deg_to_rad(_open_rotation))
	var open_basis := Basis(quaternion * open_quat)
	var open_origin: Vector3 = position + _open_position
	return Transform3D(open_basis, open_origin)


func get_save_data() -> Dictionary:
	transform = _start_transform
	var data: Dictionary = {
		"is_open": _is_open,
		"open_speed": _open_speed,
		"open_pos": var_to_str(_open_position),
		"open_rot": var_to_str(_open_rotation),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_is_open = data.is_open
		_open_speed = data.open_speed
		_open_position = str_to_var(data.open_pos)
		_open_rotation = str_to_var(data.open_rot)
