extends Node3D


func _ready() -> void:
	%CloseButton.pressed.connect(_on_close_button_pressed)


func _on_close_button_pressed() -> void:
	LevelManager.load_level(Globals.MAIN_MENU_PATH)
