extends Node3D


func _ready() -> void:
	# Connect signals
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)


func _on_vending_machine_code_submitted(code: String, _valid: bool) -> void:
	match code:
		"1996":
			var scene_path: String = "res://levels/train_station/train_station.tscn"
			var spawn_transform: Transform3D = $TrainStationSpawnPoint.global_transform
			EventBus.load_level.emit(scene_path, spawn_transform)
