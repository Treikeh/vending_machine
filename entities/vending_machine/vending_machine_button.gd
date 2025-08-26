extends Node3D


signal presssed(button_number: String)


@export var _button_number: String = "0"
@export_enum("Normal", "Accept", "Decline") var _button_colour: int = 0
@export var _mesh: Node3D
@export var _number_label: Label3D
@export var _press_sound: AudioStreamPlayer3D

var _tween: Tween


func _ready() -> void:
	_set_button(_button_colour)
	_number_label.text = _button_number


func _on_interact_area_3d_interacted(_instigator: Node3D) -> void:
	# Only allow the button to be pressed when it's not animating
	if not is_instance_valid(_tween):
		presssed.emit(_button_number)
		_press_sound.play(0.0)
		
		# Animate button press with tweens
		_tween = create_tween().chain()
		# Move button in
		_tween.tween_property(_mesh, "position", Vector3(0.0, 0.0, 0.03), 0.05)
		# Move button out
		_tween.tween_property(_mesh, "position", Vector3.ZERO, 0.05)
		# Clear tween when finished
		await _tween.finished
		_tween = null


func _set_button(value: int) -> void:
	# Hide and reset position of all buttons
	for child: Node3D in _mesh.get_children():
		if child is Label3D:
			continue
		child.hide()
		child.position = Vector3.ZERO
	
	# Show the choosen soda can
	_mesh.get_child(value).show()
