extends Node
## This script is responsible for saving/loaidng save data form a file and to store that data so
## other scenes can use it.


const SAVE_FILE_NAME: String = "savegame.ini"
const IMAGES_SAVE_DIR: String = "/pictures/"

var _save_data: Dictionary = {}
var _images_to_save: Dictionary[String, Image] = {}

@onready var _save_file_path: String = Utility.get_data_dir_path() + SAVE_FILE_NAME
@onready var _img_save_path: String = Utility.get_data_dir_path() + IMAGES_SAVE_DIR


func _ready() -> void:
	_save_data = Utility.load_data_from_file(_save_file_path)


func _exit_tree() -> void:
	_save_all_new_images()
	Utility.save_data_to_file(_save_file_path, _save_data)


func add_save_data(key:String, data: Dictionary) -> void:
	_save_data[key] = data


func get_save_data(key: String) -> Dictionary:
	return _save_data[key] if _save_data.has(key) else {}


func save_image(img_name: String, img: Image) -> void:
	_images_to_save[img_name] = img


func get_image(img_name: String) -> Image:
	if _images_to_save.has(img_name):
		return _images_to_save[img_name]
	elif FileAccess.file_exists(_img_save_path + img_name):
		return Image.load_from_file(_img_save_path + img_name)
	return null


func _save_all_new_images() -> void:
	if not DirAccess.dir_exists_absolute(_img_save_path):
		DirAccess.make_dir_absolute(_img_save_path)
	
	for img: String in _images_to_save:
		_images_to_save[img].save_png(_img_save_path + img)


#region Persistent Nodes

func save_persistent_nodes(root: Node3D, persistent_nodes: Array[Node3D]) -> Dictionary:
	print("%s is starting to save persistent nodes" % root.name)
	var persistent_nodes_data: Dictionary = {}
	
	for node: Node3D in persistent_nodes:
		# Check if node can be saved
		if not node.is_in_group("persistent"):
			continue
		
		print("%s is trying to save %s" % [root.name, node.name])
		#NOTE I need to set the save data before I set the transform so that scenes that are
		# dependent on their transform (e.g. doors) can reset their transform first.
		var save_data: Dictionary = node.get_save_data()
		var is_descendant: bool = root.is_ancestor_of(node)
		# Get the transform relative to the root node so that non descendant nodes will spawn in the
		# right position even if the root node is spawned in different location.
		var relative_transform : = root.global_transform.affine_inverse() * node.global_transform
		
		#var node_id: String = str(id) + ":" + node.name
		persistent_nodes_data[str(node.get_path())] = {
			"scene_file_path": node.scene_file_path,
			"is_descendant": is_descendant,
			"transform": var_to_str(node.transform if is_descendant else relative_transform),
			"save_data": save_data,
			#TODO: Find a way to reconnect signals on persistent nodes
			#"connected_signals": {},
		}
		# Remove nodes from persistent group so that other levels can't save it.
		node.remove_from_group("persistent")
		if not is_descendant:
			node.queue_free()
	return persistent_nodes_data


func load_persistent_nodes(root: Node3D, persistent_nodes_data: Dictionary) -> void:
	# Remove all old persistent nodes under the root node
	for node: Node in get_tree().get_nodes_in_group("persistent"):
		if root.is_ancestor_of(node):
			node.queue_free()
	
	# Wait a frame so that set the names of the new nodes
	await get_tree().process_frame
	
	# Sort persistent nodes data so that nodes higher in the scene tree are spawned first
	# e.g. /root/level/node is spawned before /root/level/node/child
	persistent_nodes_data.sort()
	
	# Spawn persistant nodes
	for node_path: String in persistent_nodes_data:
		var node_data: Dictionary = persistent_nodes_data[node_path]
		var scene: PackedScene = load(node_data.scene_file_path)
		var node: Node3D = scene.instantiate()
		
		# Divide the node_path into the name of the node and the path to the nodes parent
		var path_split: PackedStringArray = node_path.split("/")
		var node_name: String = path_split[-1]
		var parent_path: String = node_path.left(-(node_name.length() + 1))
		
		node.name = node_name
		print("%s is trying to load %s" % [root.name, node.name])
		if node_data.is_descendant:
			node.transform = str_to_var(node_data.transform)
		else:
			node.global_transform = root.global_transform * str_to_var(node_data.transform)
		
		var parent: Node = get_node(parent_path)
		parent.add_child(node)
		node.load_save_data(node_data.save_data)

#endregion
