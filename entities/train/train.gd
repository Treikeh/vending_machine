class_name Train
extends PathFollow3D
#TODO: Find a way to preserve momentum when leaving the train (Not necessary for the game)

@export var _max_speed: float = 10.0
@export var _accel_duration: float = 5.0
@export var _tarin_body: CharacterBody3D
@export var _station_wait_timer: Timer

var _speed: float = _max_speed


func _physics_process(delta: float) -> void:
	progress += _speed * delta
	_tarin_body.velocity = -_tarin_body.global_basis.x * _speed


func _on_reparent_area_body_entered(body: Node3D) -> void:
	if not is_ancestor_of(body):
		body.reparent.call_deferred(self)


func _on_reparent_area_body_exited(body: Node3D) -> void:
	if is_ancestor_of(body) and body.process_mode != ProcessMode.PROCESS_MODE_DISABLED:
		body.reparent.call_deferred(LevelManager)
		if body is RigidBody3D:
			body.apply_central_impulse(_tarin_body.velocity)


func start() -> void:
	var accel_tween: Tween = create_tween()
	accel_tween.tween_property(self, "_speed", _max_speed, _accel_duration)


func stop() -> void:
	var deaccel_tween: Tween = create_tween()
	deaccel_tween.tween_property(self, "_speed", 0.0, _accel_duration)
	deaccel_tween.tween_callback(_station_wait_timer.start)


#region Save/Load

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"progress": progress,
		"persistent_nodes": SaveManager.save_persistent_nodes(self),
	}
	print("%s data saved" % name)
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		progress = data.progress
		print("%s is loading data" % name)
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)

#endregion
