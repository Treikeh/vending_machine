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

@onready var _start_transform: Transform3D = transform
@onready var _open_transform: Transform3D = _get_open_transform()


func _ready() -> void:
	# Connect signals
	interacted.connect(_on_interacted)


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
