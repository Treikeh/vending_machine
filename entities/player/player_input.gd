class_name PlayerInput
extends Node


signal looked(vector: Vector2)
signal moved(dir: Vector2)
signal jumped(pressed: bool)
signal interacted
signal item_used
signal item_thrown(pressed: bool)


var camera_sensitivity: float = 0.1


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_load_input_settings()
	SettingsManager.input_settings_changed.connect(_load_input_settings)


func _load_input_settings() -> void:
	var input_settings: Dictionary = SettingsManager.load_input_settings()
	camera_sensitivity = input_settings.camera_sensitivity


func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Look input
		if event is InputEventMouseMotion:
			var look_x: float = -deg_to_rad(event.relative.x * camera_sensitivity)
			var look_y: float = -deg_to_rad(event.relative.y * camera_sensitivity)
			looked.emit(Vector2(look_x, look_y))
		
		# Jump input
		if event.is_action_pressed("jump"):
			jumped.emit(true)
		elif event.is_action_released("jump"):
			jumped.emit(false)
		
		if event.is_action_pressed("interact"):
			interacted.emit()
		
		# Use item input
		if event.is_action_pressed("use_item"):
			item_used.emit()
		
		# Throw item input
		if event.is_action_pressed("throw_item"):
			item_thrown.emit(true)
		elif event.is_action_released("throw_item"):
			item_thrown.emit(false)
		
		# Move input
		moved.emit(Input.get_vector("move_l", "move_r", "move_f", "move_b"))
		
		# Show mouse cursor
		#if event.is_action_pressed("ui_cancel"):
		#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Hide mouse cursor when clicking on the game
	#elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and event is InputEventMouseButton:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
