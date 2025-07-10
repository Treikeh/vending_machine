extends Node3D


@onready var _train: CharacterBody3D = %Train
@onready var _reparent_area: Area3D = %ReparentArea
@onready var _start_train_area: InteractArea3D = %StartTrainArea
@onready var _stop_train_area: Area3D = %StopTrainArea


func _ready() -> void:
	_reparent_area.body_entered.connect(_on_reparent_area_body_entered)
	_reparent_area.body_exited.connect(_on_reparent_area_body_exited)
	_start_train_area.interacted.connect(_on_start_train_area_interacted)
	_stop_train_area.body_entered.connect(_on_stop_train_area_body_entered)
	_train.velocity.x = 10.0


func _physics_process(_delta: float) -> void:
	_train.move_and_slide()


func _on_reparent_area_body_entered(body: Node3D) -> void:
	# Only reparent the body if it isn't a child of the train
	if body.get_parent() != _train:
		body.reparent.call_deferred(_train)
		print("Enter")


func _on_reparent_area_body_exited(body: Node3D) -> void:
	# Only reparent the body if it's a child of the train
	if body.get_parent() == _train:
		Globals.main.attach_to_world_3d.call_deferred(body)
		print("Exit")


func _on_start_train_area_interacted(_instigator: Node3D) -> void:
	_train.velocity.x = 10.0


func _on_stop_train_area_body_entered(body: Node3D) -> void:
	if body == _train:
		_train.velocity.x = 0.0
