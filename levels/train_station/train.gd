class_name Train
extends PathFollow3D
#TODO: Find a way to preserve momentum when leaving the train (Not necessary for the game)

@export var max_speed: float = 10.0
@export var accel_duration: float = 5.0

var speed: float = max_speed

@onready var _reparent_area: Area3D = %ReparentArea
@onready var _station_wait_timer: Timer = $StationWaitTimer


func _ready() -> void:
	_reparent_area.body_entered.connect(_on_reparent_area_body_entered)
	_reparent_area.body_exited.connect(_on_reparent_area_body_exited)
	_station_wait_timer.timeout.connect(start)


func _physics_process(delta: float) -> void:
	progress += speed * delta


func _on_reparent_area_body_entered(body: Node3D) -> void:
	if not is_ancestor_of(body):
		body.reparent.call_deferred(self)


func _on_reparent_area_body_exited(body: Node3D) -> void:
	if is_ancestor_of(body):
		reparent.call_deferred(LevelManager)


func start() -> void:
	var accel_tween: Tween = create_tween()
	accel_tween.tween_property(self, "speed", max_speed, accel_duration)


func stop() -> void:
	var deaccel_tween: Tween = create_tween()
	deaccel_tween.tween_property(self, "speed", 0.0, accel_duration)
	deaccel_tween.tween_callback(_station_wait_timer.start)
	
