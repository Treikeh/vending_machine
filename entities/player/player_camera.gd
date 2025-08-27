extends Camera3D


func _ready() -> void:
	_load_video_settings()
	SettingsManager.fov_updated.connect(_on_fov_updated)
	SettingsManager.video_settings_changed.connect(_load_video_settings)


func _load_video_settings() -> void:
	var settings: Dictionary = SettingsManager.load_video_settings()
	fov = settings.field_of_view


func _on_fov_updated(value: float) -> void:
	fov = value


#region Head bobbing

@export_group("Head bobbing")
@export var hb_frequency: float = 2.5
@export var hb_amplitude: float = 0.025
var hb_time: float = 0.0


func apply_head_bobbing(velocity: Vector3, delta: float) -> void:
	hb_time += delta * velocity.length()
	var horizontal: float = sin(hb_time * hb_frequency * 0.5) * hb_amplitude
	var vertical: float = sin(hb_time * hb_frequency) * hb_amplitude
	transform.origin = Vector3(horizontal, vertical, 0.0)

#endregion


#region Camera tilt

@export_group("Camera tilt")
@export var max_tilt: float = 3.0
@export var tilt_speed: float = 1.0


func apply_camera_tilt(velocity: Vector3, input: Vector3, delta: float) -> void:
	var dir_dot: float = 0.0
	if input:
		# Calculate how much the player is moving towards the right
		dir_dot = global_basis.x.dot(velocity.normalized())
	# Rotate camera z towards max_tilt multiplied by how much the player is moving towards the right
	rotation.z = lerp_angle(rotation.z, -deg_to_rad(max_tilt) * dir_dot, tilt_speed * delta)

#endregion
