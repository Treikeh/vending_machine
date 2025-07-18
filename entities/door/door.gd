extends InteractArea3D


## How long time it takes for the door to open/close
@export var open_speed: float = 0.5
## How much the door will rotate when opening
@export var open_rotation: Vector3 = Vector3(0.0, 90.0, 0.0)
@export var transition_type: Tween.TransitionType

var is_open: bool = false

@onready var start_quat := quaternion
@onready var open_quat := Quaternion.from_euler(Globals.vec3_deg_to_rad(open_rotation))


func _ready() -> void:
	# Connect signals
	interacted.connect(_on_interacted)


func _on_interacted(_instigator: Node3D) -> void:
	if is_open:
		is_open = false
		var tween: Tween = create_tween()
		tween.set_trans(transition_type)
		tween.tween_property(self, "quaternion", start_quat, open_speed)
	else:
		is_open = true
		var tween: Tween = create_tween()
		tween.set_trans(transition_type)
		tween.tween_property(self, "quaternion", start_quat * open_quat, open_speed)
