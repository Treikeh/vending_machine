extends Node3D


@export_range(1, 99) var trash_capacity: int = 15
var items_trashed: int = 0


func _on_destroy_area_body_entered(body: Node3D) -> void:
	if body.has_method("destroy_item") and items_trashed < trash_capacity:
		items_trashed += 1
		body.destroy_item(self)
