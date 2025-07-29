class_name BaseItem
extends RigidBody3D


signal used
signal picked_up
signal dropped
signal destroyed


func _on_interacted(instigator: Node3D) -> void:
	if instigator.has_method("pick_up_item"):
		instigator.pick_up_item(self)


## Functions to call from other scripts

func use_item(instigator: Node3D) -> void:
	_item_used(instigator)
	used.emit()


func pick_up_item(instigator: Node3D) -> void:
	_item_picked_up(instigator)
	picked_up.emit()
	linear_velocity = Vector3.ZERO
	remove_from_group("persistent")
	process_mode = Node.PROCESS_MODE_DISABLED


func drop_item(instigator: Node3D) -> void:
	_item_dropped(instigator)
	dropped.emit()
	add_to_group("persistent")
	process_mode = Node.PROCESS_MODE_INHERIT


func destroy_item(instigator: Node3D) -> void:
	_item_destroyed(instigator)
	destroyed.emit()
	queue_free()


## Functions to override in child classes

@warning_ignore_start("unused_parameter")
func _item_used(instigator: Node3D) -> void:
	pass


func _item_picked_up(instigator: Node3D) -> void:
	pass


func _item_dropped(instigator: Node3D) -> void:
	pass


func _item_destroyed(instigator: Node3D) -> void:
	pass


#region Save/Load

func get_save_data() -> Dictionary:
	return {}


func load_save_data(data: Dictionary) -> void:
	pass

#endregion
