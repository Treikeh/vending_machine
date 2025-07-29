extends Node
## This script is responsible for saving/loaidng save data form a file and to store that data so
## other scenes can use it.


const USER_PATH: String = "user://savegame.save"
const DEBUG_PATH: String = "res://debug/savegame.ini"


var _file_access: FileAccess
var _save_data: Dictionary

@onready var _save_path: String = DEBUG_PATH if OS.is_debug_build() else USER_PATH


func _ready() -> void:
	_load_data_from_file()


func _exit_tree() -> void:
	#_save_data_to_file()
	pass


func add_save_data(key:String, data: Dictionary) -> void:
	_save_data[key] = data


func get_save_data(key: String) -> Dictionary:
	return _save_data[key] if _save_data.has(key) else {}


func _save_data_to_file() -> void:
	# Create/open a file to write to
	_file_access = FileAccess.open(_save_path, FileAccess.WRITE)
	# Turn _save_data dict into a string and save it on the save file
	_file_access.store_string(JSON.stringify(_save_data, "\t"))
	_file_access.close()


func _load_data_from_file() -> void:
	# Check if save file exists
	if FileAccess.file_exists(_save_path):
		# Open save file so that data can be read from it
		_file_access = FileAccess.open(_save_path, FileAccess.READ)
		# Parse the save file and set the _save_dict to the result
		_save_data = JSON.parse_string(_file_access.get_as_text())
		_file_access.close()


#region Persistent Nodes

const SAVE_LAYER := int(pow(2, 24-1))


func save_persistent_nodes(root: Node3D) -> Dictionary:
	var persistent_nodes_data: Dictionary = {}
	var id: int = 0
	
	# Iterate over every persistent ndoe
	for node: Node3D in get_tree().get_nodes_in_group("persistent"):
		# Make sure node isn't the root and that it's still in the persistent group
		if node == root or not node.is_in_group("persistent"):
			continue
		
		# Check if node can be saved
		var is_descendant: bool = root.is_ancestor_of(node)
		var in_level_bounds: bool = false
		if not is_descendant:
			in_level_bounds = _is_node_in_level(node, root)
		
		# Save node data
		if is_descendant or in_level_bounds:
			#NOTE I need to set the save data before I set the transform so that scenes that are
			# dependent on their transform (e.g. doors) can reset their transform first.
			var save_data: Dictionary = node.get_save_data()
			var relative_transform : = root.global_transform.affine_inverse() * node.global_transform
			var node_id: String = str(id) + ":" + node.name
			persistent_nodes_data[node_id] = {
				"name": node.name,
				"scene_file_path": node.scene_file_path,
				"parent_path": node.get_parent().get_path(),
				"is_descendant": is_descendant,
				"transform": var_to_str(node.transform if is_descendant else relative_transform),
				"save_data": save_data,
				#TODO: Find a way to reconnect signals on persistent nodes
				#"connected_signals": {},
			}
			# Remove nodes
			node.remove_from_group("persistent")
			if not is_descendant:
				node.queue_free()
			id += 1
	return persistent_nodes_data


## Send a ray down form the node and check if it hits a descendant of the level
func _is_node_in_level(node: Node3D, level: Node3D, distance: float = 100.0) -> bool:
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	var from: Vector3 = node.global_position
	var to: Vector3 = from + (Vector3.DOWN * distance)
	var mask: int = SAVE_LAYER
	var ray_query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, mask)
	var result: Dictionary = space.intersect_ray(ray_query)
	if result and level.is_ancestor_of(result.collider):
		return true
	return false


func load_persistent_nodes(root: Node3D, persistent_nodes_data: Dictionary) -> void:
	# Remove all old persistent nodes under the root node
	for node: Node in get_tree().get_nodes_in_group("persistent"):
		if root.is_ancestor_of(node):
			node.queue_free()
	
	await root.get_tree().process_frame
	
	# Spawn persistant nodes on the root node
	for node_id: String in persistent_nodes_data:
		var node_data: Dictionary = persistent_nodes_data[node_id]
		var scene: PackedScene = load(node_data.scene_file_path)
		var node: Node3D = scene.instantiate()
		
		node.name = node_data.name
		if node_data.is_descendant:
			node.transform = str_to_var(node_data.transform)
		else:
			node.global_transform = root.global_transform * str_to_var(node_data.transform)
		
		var parent: Node = get_node(node_data.parent_path)
		parent.add_child(node)
		node.load_save_data(node_data.save_data)

#endregion
