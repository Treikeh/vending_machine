extends Node3D


@export var ui: Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%PlayButton.pressed.connect(_on_play_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%QuitButton.pressed.connect(_on_quit_button_pressed)



func _on_play_button_pressed() -> void:
	Globals.main.load_level("uid://b64kpf3puwh5f")


func _on_settings_button_pressed() -> void:
	ui.hide()
	# Spawn inn the settings menu
	var settings_menu_scene: PackedScene = load("uid://t0lpsh2ot3se")
	var settings_menu: Control = settings_menu_scene.instantiate()
	add_child(settings_menu)
	settings_menu.tree_exiting.connect(_on_setting_menu_closed)


func _on_setting_menu_closed() -> void:
	ui.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
