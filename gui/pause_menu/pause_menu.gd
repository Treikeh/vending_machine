extends Control


func _ready() -> void:
	get_tree().paused = true
	
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	%QuitButton.pressed.connect(_on_quit_button_pressed)


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()


func _on_settings_button_pressed() -> void:
	hide()
	# Spawn settings menu
	var settings_menu: Control = load("uid://t0lpsh2ot3se").instantiate()
	EventBus.add_ui_scene.emit(settings_menu)
	settings_menu.tree_exiting.connect(_on_settings_menu_tree_exiting)


func _on_settings_menu_tree_exiting() -> void:
	show()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	EventBus.load_level.emit("uid://wwxe07fon8hy")
	EventBus.remove_all_ui_scenes.emit()



func _on_quit_button_pressed() -> void:
	get_tree().quit()
