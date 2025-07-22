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
	var settings_menu: Control = GuiManager.load_menu(Globals.SETTINGS_MENU_PATH)
	settings_menu.tree_exiting.connect(_on_settings_menu_closed)


func _on_settings_menu_closed() -> void:
	show()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	# Load main menu
	LevelManager.load_level(Globals.MAIN_MENU_PATH)
	GuiManager.unload_all_menus()



func _on_quit_button_pressed() -> void:
	get_tree().quit()
