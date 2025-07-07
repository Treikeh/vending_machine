extends Node3D


@export var train_station_tunnel_spawn_point: Marker3D
var buy_count: int = 0


func _ready() -> void:
	# Hide and disable trash can when the game starts
	_disable_trash_can()
	# Connect signals
	Globals.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)
	
	# Spawn world environment that is independent from level
	Globals.main.load_level(Globals.WORLD_ENV_PATH, global_transform)


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		buy_count += 1
	
	match code:
		"1996":
			# Spawn train station tunnel
			var scene_path: String = "res://levels/train_station_tunnel/train_station_tunnel.tscn"
			var spawn_transform: Transform3D = train_station_tunnel_spawn_point.global_transform
			Globals.main.load_level(scene_path, spawn_transform)
			$Ground/CSGBox3D.show()


@export_group("Trash can")
## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var trash_can_become_visible_buy_count: int = 5
@export var trash_can: Node3D


func _on_trash_can_visible_on_screen_notifier_screen_exited() -> void:
	if not trash_can.visible and buy_count >= trash_can_become_visible_buy_count:
		_enable_trash_can()


func _enable_trash_can() -> void:
	trash_can.show()
	trash_can.process_mode = Node.PROCESS_MODE_INHERIT


func _disable_trash_can() -> void:
	trash_can.hide()
	trash_can.process_mode = Node.PROCESS_MODE_DISABLED
