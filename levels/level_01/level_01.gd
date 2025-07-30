extends Level3D


var _buy_count: int = 0


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		_buy_count += 1
	
	# Allow the train station tunnel to spawn when typing in the right code
	if code == "1996":
		_tunnel_state = Tunnel_State.CAN_SPAWN
	
	if code == "666":
		# Spawn elevator
		pass
	
	if code == "41":
		# Spawn basketball hoop
		pass


#region Train station tunnel

enum Tunnel_State {HIDDEN, CAN_SPAWN, SPAWNED}

@export_group("Train station tunnel")
@export var _train_station_tunnel_spawn_point: Marker3D
@export var _tunnel_path: Node3D

var _tunnel_state: Tunnel_State = Tunnel_State.HIDDEN


func _on_tunnel_path_screen_notifier_screen_exited() -> void:
	if _tunnel_state == Tunnel_State.CAN_SPAWN:
		_spawn_train_station_tunnel()
		_tunnel_state = Tunnel_State.SPAWNED


func _spawn_train_station_tunnel() -> void:
	var scene_path: String = "uid://gqsmdnolrjqo"
	var spawn_transform: Transform3D = _train_station_tunnel_spawn_point.global_transform
	LevelManager.load_level(scene_path, spawn_transform)
	_tunnel_path.hide()
	_tunnel_path.process_mode = Node.PROCESS_MODE_DISABLED

#endregion



#region Trash can

@export_group("Trash can")
## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var _trash_can_become_visible_buy_count: int = 5
@export var _trash_can: StaticBody3D


func _on_trash_can_screen_notifier_screen_exited() -> void:
	if _buy_count >= _trash_can_become_visible_buy_count and not _trash_can.visible:
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

func get_save_data() -> Dictionary:
	var overlapping_nodes: Array[Node3D] = Utility.get_overlapping_nodes(level_bounds)
	var data: Dictionary = {
		"buy_count": _buy_count,
		"trash_can_visible": _trash_can.visible,
		"tunnel_state": _tunnel_state,
		"persistent_nodes": SaveManager.save_persistent_nodes(self, overlapping_nodes),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_buy_count = data.buy_count
		
		_set_trash_can_state(data.trash_can_visible)
		
		_tunnel_state = data.tunnel_state
		if _tunnel_state == Tunnel_State.SPAWNED:
			_spawn_train_station_tunnel()
		
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)
	else:
		_set_trash_can_state(false)

#endregion
