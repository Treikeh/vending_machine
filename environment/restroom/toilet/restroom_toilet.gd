extends Node3D


const OPEN_ROT: float = 92.5
const CLOSED_ROT: float = 0.0
const OPEN_TWEEN_DURATION: float = 0.5

@export var _lid: Node3D

var _is_open: bool = false
var _open_tween: Tween


func _on_lid_interact_area_interacted(_instigator: Node3D) -> void:
	if _open_tween:
		_open_tween.stop()
	
	_open_tween = create_tween()
	var new_rot: float = CLOSED_ROT if _is_open else OPEN_ROT
	_open_tween.tween_property(_lid, "rotation_degrees:x", new_rot, OPEN_TWEEN_DURATION)
	
	_is_open = not _is_open
