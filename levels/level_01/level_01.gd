extends Node3D


@export var train_station_tunnel_spawn_point: Marker3D

var buy_count: int = 0

@onready var _tunnel_path: CSGBox3D = %TunnelPath


func _ready() -> void:
	# Load level save data
	_load_data()
	
	# Connect signals
	tree_exiting.connect(_save_data)
	Globals.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)
	
	# Spawn world environment that is independent from level
	Globals.main.load_level(Globals.WORLD_ENV_PATH, global_transform)


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		buy_count += 1
	
	match code:
		"1996":
			_spawn_train_station_tunnel()


func _spawn_train_station_tunnel() -> void:
	var scene_path: String = "uid://gqsmdnolrjqo"
	var spawn_transform: Transform3D = train_station_tunnel_spawn_point.global_transform
	Globals.main.load_level(scene_path, spawn_transform)
	_tunnel_path.show()


@export_group("Trash can")
## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var trash_can_become_visible_buy_count: int = 5

@onready var _trash_can: StaticBody3D = %TrashCan


func _on_trash_can_visible_on_screen_notifier_screen_exited() -> void:
	if not _trash_can.visible and buy_count >= trash_can_become_visible_buy_count:
		_set_trash_can_state(true)


func _set_trash_can_state(active: bool) -> void:
	if active:
		_trash_can.show()
		_trash_can.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		_trash_can.hide()
		_trash_can.process_mode = Node.PROCESS_MODE_DISABLED



#region Save/Load

func _save_data() -> void:
	var data: Dictionary = {
		"buy_count": buy_count,
		"trash_can": {
			"visible": _trash_can.visible,
		},
		"tunnel_path": {
			"visible": _tunnel_path.visible,
		},
	}
	
	SaveManager.add_save_data(scene_file_path, data)


func _load_data() -> void:
	var data: Dictionary = SaveManager.get_save_data(scene_file_path)
	if not data.is_empty():
		buy_count = data.buy_count
		
		_set_trash_can_state(data.trash_can.visible)
		
		_tunnel_path.visible = data.tunnel_path.visible
		if _tunnel_path.visible:
			_spawn_train_station_tunnel()
	else:
		print("No level data found for scene %s" % scene_file_path)
		_set_trash_can_state(false)

#endregion
