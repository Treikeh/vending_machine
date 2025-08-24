extends Level3D


var _buy_count: int = 0


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		_buy_count += 1
		# Allow trash can to become visible when buying enough stuff
		if _buy_count >= _trash_can_become_visible_buy_count:
			_trash_can_can_become_visible = true
			if not _trash_can_screen_notifier.is_on_screen():
				_set_node_active(_trash_can, true)
	
	# Do stuff when typing in the right codes
	match code:
		"41": # Basketball
			_basketball_bought = true
			if not _basketball_hoop_screen_notifier.is_on_screen():
				_set_node_active(_basketball_hoop, true)
				
		"666": # Hell elevator
			_show_hellevator()
		"1996": # Train station tunnel
			_tunnel_state = Tunnel_State.CAN_SPAWN
			if not _tunnel_path_screen_notifier.is_on_screen():
				_spawn_train_station_tunnel()


func _set_node_active(
		node: Node3D,
		active: bool,
		active_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT
) -> void:
	if active:
		node.show()
		node.process_mode = active_process_mode
	else:
		node.hide()
		node.process_mode = Node.PROCESS_MODE_DISABLED


#region Train station tunnel

enum Tunnel_State {HIDDEN, CAN_SPAWN, SPAWNED}

@export_group("Train station tunnel")
@export var _train_station_tunnel_spawn_point: Marker3D
@export var _tunnel_path: Node3D
@export var _tunnel_path_screen_notifier: VisibleOnScreenNotifier3D

var _tunnel_state: Tunnel_State = Tunnel_State.HIDDEN: set = _set_tunnel_state


func _set_tunnel_state(value: Tunnel_State) -> void:
	_tunnel_state = value
	if _tunnel_state == Tunnel_State.SPAWNED:
		_tunnel_path.hide()
		_tunnel_path.process_mode = Node.PROCESS_MODE_DISABLED


func _on_tunnel_path_screen_notifier_screen_exited() -> void:
	if _tunnel_state == Tunnel_State.CAN_SPAWN:
		_spawn_train_station_tunnel()


func _spawn_train_station_tunnel() -> void:
	_tunnel_state = Tunnel_State.SPAWNED
	var scene_path: String = "uid://gqsmdnolrjqo"
	var spawn_transform: Transform3D = _train_station_tunnel_spawn_point.global_transform
	LevelManager.load_level(scene_path, spawn_transform)

#endregion



#region Hell

const HELLEVATOR_MOVE_TIME: float = 5.0

@export_group("Hell")
@export var _hellevator: Node3D


func _show_hellevator() -> void:
	_hellevator.position.y = -4.0
	_set_node_active(_hellevator, true)
	
	var move_tween: Tween = create_tween()
	move_tween.tween_property(_hellevator, "position:y", 0.0, HELLEVATOR_MOVE_TIME)


func _set_hellevator_active(active: bool) -> void:
	if active:
		_hellevator.show()
		_hellevator.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		_hellevator.hide()
		_hellevator.process_mode = Node.PROCESS_MODE_DISABLED

#endregion



#region Trash can

@export_group("Trash can")
## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var _trash_can_become_visible_buy_count: int = 5
@export var _trash_can_screen_notifier: VisibleOnScreenNotifier3D
@export var _trash_can: StaticBody3D

var _trash_can_can_become_visible: bool = false


func _on_trash_can_screen_notifier_screen_exited() -> void:
	if _trash_can_can_become_visible and not _trash_can.visible:
		_set_node_active(_trash_can, true)

#endregion



#region Basketball hoop

@export_group("Basketball hoop")
@export var _basketball_hoop_screen_notifier: VisibleOnScreenNotifier3D
@export var _basketball_hoop: Node3D

var _basketball_bought: bool = false


func _on_basketball_hioop_screen_notifier_screen_exited() -> void:
	if _basketball_bought and not _basketball_hoop.visible:
		_set_node_active(_basketball_hoop, true)

#endregion



#region Save/Load

func get_save_data() -> Dictionary:
	var overlapping_nodes: Array[Node3D] = Utility.get_overlapping_nodes(level_bounds)
	var data: Dictionary = {
		"buy_count": _buy_count,
		"tunnel_state": _tunnel_state,
		"hellevator_visible": _hellevator.visible,
		"trash_can_visible": _trash_can.visible,
		"basketball_hoop_visible": _basketball_hoop.visible,
		"persistent_nodes": SaveManager.save_persistent_nodes(self, overlapping_nodes),
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_buy_count = data.buy_count
		
		_tunnel_state = data.tunnel_state
		
		_set_node_active(_hellevator, data.hellevator_visible)
		_set_node_active(_trash_can, data.trash_can_visible)
		_set_node_active(_basketball_hoop, data.basketball_hoop_visible)
		
		SaveManager.load_persistent_nodes(self, data.persistent_nodes)
	else:
		_set_node_active(_hellevator, false)
		_set_node_active(_trash_can, false)
		_set_node_active(_basketball_hoop, false)

#endregion
