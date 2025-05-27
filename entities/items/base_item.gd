class_name BaseItem
extends RigidBody3D


signal picked_up
signal dropped
signal used


## Functions to call from other scripts

func use_item() -> void:
	_item_used()
	used.emit()


func pick_up_item(instigator: Node3D) -> void:
	_item_picked_up()
	picked_up.emit()
	linear_velocity = Vector3.ZERO
	#freeze = true
	process_mode = Node.PROCESS_MODE_DISABLED
	if instigator.has_method("pick_up_item"):
		instigator.pick_up_item(self)


func drop_item() -> void:
	_item_dropped()
	dropped.emit()
	#freeze = false
	process_mode = Node.PROCESS_MODE_INHERIT


## Functions to override in child classes

func _item_used() -> void:
	pass


func _item_picked_up() -> void:
	pass


func _item_dropped() -> void:
	pass
