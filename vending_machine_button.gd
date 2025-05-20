extends Node3D


signal presssed(button_number: String)


@export var button_number: String = "0"
@export var mesh: Node3D
@export var number_label: Label3D
@export var press_sound: AudioStreamPlayer3D

var tween: Tween


func _ready() -> void:
	number_label.text = button_number


func _on_interact_area_3d_interacted() -> void:
	# Only allow the button to be pressed when it's not animating
	if not is_instance_valid(tween):
		presssed.emit(button_number)
		press_sound.play(0.0)
		
		# Animate button press with tweens
		tween = create_tween().chain()
		# Move button in
		tween.tween_property(mesh, "position", Vector3(0.0, 0.0, 0.03), 0.1)
		# Move button out
		tween.tween_property(mesh, "position", Vector3.ZERO, 0.1)
		# Clear tween when finished
		await tween.finished
		tween = null
