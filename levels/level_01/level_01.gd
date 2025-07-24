extends Level3D


@export var _vending_machine: Node3D

var _buy_count: int = 0


func _ready() -> void:
	# Spawn world environment that is independent from level
	LevelManager.load_level(Globals.WORLD_ENV_PATH, global_transform)
	
	# Connect signals
	_vending_machine.code_submitted.connect(_on_vending_machine_code_submitted)


func _on_vending_machine_code_submitted(code: String, valid: bool) -> void:
	if valid:
		_buy_count += 1
	
	# Allow the train station tunnel to spawn when typing in the right code
	if code == "1996":
		_tunnel_state = Tunnel_State.CAN_SPAWN


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

func save_data() -> Dictionary:
	var data: Dictionary = {
		"buy_count": _buy_count,
		"trash_can_visible": _trash_can.visible,
		"tunnel_state": _tunnel_state,
		"persistent_nodes": {},
	}
	
	# Get all overlapping persistent bodies in the level
	var body_id: int = 0
	for body: Node3D in get_overlapping_bodies():
		if body.has_method("save_data"):
			# Remove the body at the end of the frame if it's not a descendant
			var is_descendant: bool = is_ancestor_of(body)
			if not is_descendant:
				body.queue_free.call_deferred()
			
			data.persistent_nodes[body_id] = {
				"scene_file_path": body.scene_file_path,
				"is_descendant": is_descendant,
				"data": body.save_data(),
			}
			body_id += 1
			print(body.name, "is an persistent overlapping body")
	return data


func with_data(data: Dictionary) -> Level3D:
	if not data.is_empty():
		_buy_count = data.buy_count
		
		_set_trash_can_state(data.trash_can_visible)
		
		_tunnel_state = data.tunnel_state
		if _tunnel_state == Tunnel_State.SPAWNED:
			_spawn_train_station_tunnel()
		
		# Spawn persistant nodes
		for node_id: String in data.persistent_nodes:
			var node_data: Dictionary = data.persistent_nodes[node_id]
			var scene: PackedScene = load(node_data.scene_file_path)
			var node: Node3D = scene.instantiate().with_data(node_data.data)
			if node_data.is_descendant:
				add_child(node)
			else:
				#TODO: Replace this with a function to add the node as a child of the LevelManager
				add_child(node)
	else:
		_set_trash_can_state(false)
	
	return self

#endregion
