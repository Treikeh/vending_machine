extends Node3D


@export var max_code_length: int = 4
@export var display_label: Label3D
@export var reset_label_timer: Timer
@export var item_spawn_point: Marker3D
# NOTE: I'm a bit worried that having every single item preloaded might cause a memory problem
@export var items: Dictionary[String, PackedScene] = {
	#"11": preload("res://entities/items/soda_cans/red_soda_can.tscn"),
	"12": preload("res://entities/items/soda_cans/blue_soda_can.tscn"),
	"13": preload("res://entities/items/soda_cans/green_soda_can.tscn"),
	"14": preload("res://entities/items/soda_cans/yellow_soda_can.tscn"),
}


func _ready() -> void:
	_reset_display_label()


func _reset_display_label() -> void:
	display_label.text = ProjectSettings.get_setting("application/config/version")


func _on_vending_machine_button_presssed(button_number: String) -> void:
	if display_label.text == ProjectSettings.get_setting("application/config/version"):
		display_label.text = ""
	if reset_label_timer.is_stopped() and display_label.text.length() < max_code_length:
		display_label.text += button_number
	elif !reset_label_timer.is_stopped():
		reset_label_timer.stop()
		display_label.text = button_number


func _on_vending_machine_confirm_button_presssed(_button_number: String) -> void:
	var code: String = display_label.text
	
	match code:
		"11":
			owner.call("_on_play_button_pressed")
		"21":
			owner.call("_on_settings_button_pressed")
		"31":
			owner.call("_on_credits_button_pressed")
		"41":
			owner.call("_on_quit_button_pressed")
		_:
			if items.has(code):
				_spawn_item(items[code])
				display_label.text = "OK"
				Globals.vending_machine_code_submitted.emit(code, true)
			else:
				display_label.text = "ERR"
				Globals.vending_machine_code_submitted.emit(code, false) 
	
	# Start timer to reset label
	reset_label_timer.start(0.0)


func _on_vending_machine_cancel_button_presssed(_button_number: String) -> void:
	_reset_display_label()


func _on_reset_label_timer_timeout() -> void:
	_reset_display_label()


func _spawn_item(scene: PackedScene) -> void:
	var item: RigidBody3D = scene.instantiate()
	add_child(item)
	item.transform = item_spawn_point.transform
	item.apply_central_impulse(-item.global_basis.z * 5.0 * item.mass)
