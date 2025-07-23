extends Node3D


var _buy_count: int = 0

@onready var _vending_machine: Node3D = %VendingMachine


func _ready() -> void:
	# Load save data
	_load_data()
	
	# Spawn world environment that is independent from level
	LevelManager.load_level(Globals.WORLD_ENV_PATH, global_transform)
	
	# Connect signals
	_vending_machine.code_submitted.connect(_on_vending_machine_code_submitted)


func _exit_tree() -> void:
	_save_data()


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		_buy_count += 1
	
	# Allow the trash can to become active when buying enough items
	if _buy_count >= _trash_can_become_visible_buy_count and not _trash_can_screen_notifier.screen_exited.has_connections():
		_trash_can_screen_notifier.screen_exited.connect(_on_trash_can_screen_notifier_screen_exited)
	
	# Allow the train station tunnel to spawn when typing in the right code
	if code == "1996":
		_tunnel_path_screen_notifier.screen_exited.connect(_on_tunnel_path_screen_notifier_screen_exited)


#region Train station tunnel

@onready var _train_station_tunnel_spawn_point: Marker3D = $TrainStationTunnelSpawnPoint
@onready var _tunnel_path_screen_notifier: VisibleOnScreenNotifier3D = %TunnelPathScreenNotifier


func _on_tunnel_path_screen_notifier_screen_exited() -> void:
	_tunnel_visible = true
	_spawn_train_station_tunnel()


func _spawn_train_station_tunnel() -> void:
	var scene_path: String = "uid://gqsmdnolrjqo"
	var spawn_transform: Transform3D = _train_station_tunnel_spawn_point.global_transform
	LevelManager.load_level(scene_path, spawn_transform)
	var tunnel_path: Node3D = _tunnel_path_screen_notifier.get_parent()
	tunnel_path.hide()
	tunnel_path.process_mode = Node.PROCESS_MODE_DISABLED

#endregion



#region Trash can

@export_group("Trash can")
## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var _trash_can_become_visible_buy_count: int = 5

@onready var _trash_can: StaticBody3D = %TrashCan
@onready var _trash_can_screen_notifier: VisibleOnScreenNotifier3D = %TrashCanScreenNotifier


func _on_trash_can_screen_notifier_screen_exited() -> void:
	if not _trash_can.visible:
		_set_trash_can_state(true)


func _set_trash_can_state(active: bool) -> void:
	if active:
		_trash_can.show()
		_trash_can.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		_trash_can.hide()
		_trash_can.process_mode = Node.PROCESS_MODE_DISABLED

#endregion



#region Save/Load

var _tunnel_visible: bool = false


func _save_data() -> void:
	var data: Dictionary = {
		"buy_count": _buy_count,
		"trash_can": {
			"visible": _trash_can.visible,
		},
		"tunnel_path": {
			"visible": _tunnel_visible,
		},
	}
	
	SaveManager.add_save_data(scene_file_path, data)


func _load_data() -> void:
	var data: Dictionary = SaveManager.get_save_data(scene_file_path)
	if not data.is_empty():
		_buy_count = data.buy_count
		
		_set_trash_can_state(data.trash_can.visible)
		
		_tunnel_visible = data.tunnel_path.visible
		if _tunnel_visible:
			_spawn_train_station_tunnel()
	else:
		_set_trash_can_state(false)

#endregion
