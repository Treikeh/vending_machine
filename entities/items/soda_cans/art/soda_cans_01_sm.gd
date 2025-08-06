@tool
extends Node3D


@export_enum("Red", "Yellow", "Blue", "Green") var _colour: int = 0:
	set = _set_visible_soda_can

func _set_visible_soda_can(value: int) -> void:
	_colour = value
	# Hide and reset position of all soda cans
	for child: Node3D in get_children():
		child.hide()
		child.position = Vector3.ZERO
	
	# Show the choosen soda can
	get_child(_colour).show()
