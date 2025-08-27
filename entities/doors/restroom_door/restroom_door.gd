extends "res://entities/doors/door.gd"


enum Gender {MALE, FEMALE}

@export var _gender: Gender = Gender.MALE
@export var _male_decal: Decal
@export var _female_decal: Decal


func _ready() -> void:
	super()
	_set_gender_decals()


func _set_gender_decals() -> void:
	_male_decal.visible = true if _gender == Gender.MALE else false
	_female_decal.visible = true if _gender == Gender.FEMALE else false


func get_save_data() -> Dictionary:
	transform = _start_transform
	var data: Dictionary = {
		"is_open": _is_open,
		"open_speed": _open_speed,
		"open_pos": var_to_str(_open_position),
		"open_rot": var_to_str(_open_rotation),
		"gender": _gender,
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_is_open = data.is_open
		_open_speed = data.open_speed
		_open_position = str_to_var(data.open_pos)
		_open_rotation = str_to_var(data.open_rot)
		# Update start and open transform.
		# It's necessarry to do this here since function is called after _ready.
		_start_transform = transform
		_open_transform = _get_open_transform()
		if _is_open:
			transform = _open_transform
		_gender = data.gender
		_set_gender_decals()
