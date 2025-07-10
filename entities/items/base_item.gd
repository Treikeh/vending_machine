class_name BaseItem
extends RigidBody3D


signal used
signal picked_up
signal dropped
signal destroyed


## Functions to call from other scripts

func use_item(instigator: Node3D) -> void:
	_item_used(instigator)
	used.emit()


func pick_up_item(instigator: Node3D) -> void:
	reparent(instigator, true)
	_item_picked_up(instigator)
	picked_up.emit()
	linear_velocity = Vector3.ZERO
	#freeze = true
	process_mode = Node.PROCESS_MODE_DISABLED
	if instigator.has_method("pick_up_item"):
		instigator.pick_up_item(self)


func drop_item(instigator: Node3D) -> void:
	Globals.main.attach_to_world_3d(self)
	_item_dropped(instigator)
	dropped.emit()
	#freeze = false
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
