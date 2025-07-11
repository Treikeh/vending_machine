extends Node3D


@onready var _train: Train = %Train
@onready var _stop_train_area: Area3D = %StopTrainArea


func _ready() -> void:
	_stop_train_area.area_entered.connect(_on_stop_train_area_area_entered)


func _on_stop_train_area_area_entered(area: Area3D) -> void:
	if area.get_parent() == _train:
		_train.stop()
