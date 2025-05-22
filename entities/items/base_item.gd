extends RigidBody3D


func use_item() -> void:
	queue_free()


func _on_pick_up_area_interacted(instigator: Node3D) -> void:
	if instigator.has_method("pick_up_item"):
		instigator.pick_up_item(self)
