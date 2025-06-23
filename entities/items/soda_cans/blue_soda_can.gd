extends BaseItem


@export var normal_mesh: Node3D
@export var empty_mesh: Node3D

var empty: bool = false


func _ready() -> void:
	empty_mesh.hide()


func _item_used(instigator: Node3D) -> void:
	if !empty:
		empty = true
		empty_mesh.show()
		normal_mesh.hide()
		# Launch player upwards when drinking the can
		if instigator is RigidBody3D:
			instigator.apply_central_impulse(Vector3.UP * 10.0)
