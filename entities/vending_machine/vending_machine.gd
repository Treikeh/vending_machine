extends Node3D


@export var display_label: Label3D
@export var reset_label_timer: Timer
@export var item_spawn_point: Marker3D


var red_soda_can_scene: PackedScene = preload("res://entities/items/soda_cans/red_soda_can.tscn")
var blue_bottle_scene: PackedScene = preload("res://entities/items/soda_cans/blue_soda_can.tscn")
var green_bottle_scene: PackedScene = preload("res://entities/items/soda_cans/green_soda_can.tscn")
var yellow_bottle_scene: PackedScene = preload("res://entities/items/soda_cans/yellow_soda_can.tscn")


func _ready() -> void:
	_reset_display_label()


func _reset_display_label() -> void:
	display_label.text = ""


func _on_vending_machine_button_presssed(button_number: String) -> void:
	if reset_label_timer.is_stopped() and display_label.text.length() < 4:
		display_label.text += button_number
	elif !reset_label_timer.is_stopped():
		reset_label_timer.stop()
		display_label.text = button_number


func _on_vending_machine_confirm_button_presssed(_button_number: String) -> void:
	match display_label.text:
		"1111":
			display_label.text = "Red"
			_spawn_item(red_soda_can_scene)
		"2222":
			display_label.text = "Blue"
			_spawn_item(blue_bottle_scene)
		"3333":
			display_label.text = "Green"
			_spawn_item(green_bottle_scene)
		"4444":
			display_label.text = "Yellow"
			_spawn_item(yellow_bottle_scene)
		_:
			display_label.text = "ERROR"
	
	# Reset label after a short delay
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
