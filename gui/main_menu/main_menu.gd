extends Node3D


@export_file("*.tscn") var first_level_path: String

@onready var _ui: Control = %Ui


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Connect signals
	%PlayButton.pressed.connect(_on_play_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%QuitButton.pressed.connect(_on_quit_button_pressed)



func _on_play_button_pressed() -> void:
	Globals.main.load_level(first_level_path)


func _on_settings_button_pressed() -> void:
	_ui.hide()
	# Spawn settings menu
	var settings_menu: Control = Globals.main.load_menu(Globals.SETTINGS_MENU_PATH)
	settings_menu.tree_exiting.connect(_on_setting_menu_closed)


func _on_setting_menu_closed() -> void:
	_ui.show()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
