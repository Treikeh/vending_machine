class_name Level3D
extends Node3D
@warning_ignore_start("unused_parameter")


@export var level_bounds: VisualInstance3D


func _enter_tree() -> void:
	level_bounds.layers = 0


func get_save_data() -> Dictionary:
	return {}


func load_save_data(data: Dictionary) -> void:
	pass


func _save_persistent_nodes() -> Dictionary:
	# Get all overlapping persistent bodies in the level
	var persistent_nodes_data: Dictionary = {}
	var node_id: int = 0
	# Get all persistant noes
	for node: Node3D in get_tree().get_nodes_in_group("persistent"):
		var aabb: AABB = level_bounds.global_transform * level_bounds.get_aabb()
		var in_level_bounds: bool = aabb.has_point(node.global_position)
		
		if in_level_bounds:
			#NOTE I need to set the save data before I set the transform so that scenes that are
			# dependent on their transform (e.g. doors) can reset their transform first.
			var save_data: Dictionary = node.get_save_data()
			var is_descendant: bool = self.is_ancestor_of(node)
			var relative_transform : = global_transform.affine_inverse() * node.global_transform
			persistent_nodes_data[node_id] = {
				"scene_file_path": node.scene_file_path,
				"name": node.name,
				"parent_path": node.get_parent().get_path(),
				"is_descendant": is_descendant,
				"transform": var_to_str(node.transform if is_descendant else relative_transform),
				"save_data": save_data,
				#TODO: Find a way to reconnect signals on persistent nodes
				#"connected_signals": {},
			}
			# Remove nodes at the end of the frame
			node.queue_free.call_deferred()
			node_id += 1
	return persistent_nodes_data


func _load_persistent_nodes(persistent_nodes_data: Dictionary) -> void:
	# Remove all old nodes
	for node: Node in get_tree().get_nodes_in_group("persistent"):
		if is_ancestor_of(node):
			node.queue_free()
	
	await get_tree().process_frame
	
	# Spawn persistant nodes
	for node_id: Variant in persistent_nodes_data:
		var node_data: Dictionary = persistent_nodes_data[node_id]
		var scene: PackedScene = load(node_data.scene_file_path)
		var node: Node3D = scene.instantiate()
		
		node.name = node_data.name
		if node_data.is_descendant:
			node.transform = str_to_var(node_data.transform)
		else:
			node.global_transform = global_transform * str_to_var(node_data.transform)
		node.load_save_data(node_data.save_data)
		
		var parent: Node = get_node(node_data.parent_path)
		parent.add_child(node)
