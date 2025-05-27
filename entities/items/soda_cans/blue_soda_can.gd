extends BaseItem


@export var normal_mesh: Node3D
@export var empty_mesh: Node3D

var empty: bool = false


func _ready() -> void:
	empty_mesh.hide()


func _item_used() -> void:
	if !empty:
		empty = true
		empty_mesh.show()
		normal_mesh.hide()
