extends Node3D


@export var player_spawn_point: Marker3D
@export var train_station_tunnel_spawn_point: Marker3D


func _ready() -> void:
	# Connect signals
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)
	
	# Spawn player into the map
	var spawn_transform: Transform3D = player_spawn_point.global_transform
	EventBus.load_level.emit("res://entities/player/player_controller.tscn", spawn_transform)


func _on_vending_machine_code_submitted(code: String, _valid: bool) -> void:
	match code:
		"1996":
			# Spawn train station tunnel
			var scene_path: String = "res://levels/train_station_tunnel/train_station_tunnel.tscn"
			var spawn_transform: Transform3D = train_station_tunnel_spawn_point.global_transform
			EventBus.load_level.emit(scene_path, spawn_transform)
			$Ground/CSGBox3D.show()
