extends Node3D


func _ready() -> void:
	%CloseButton.pressed.connect(_on_close_button_pressed)


func _on_close_button_pressed() -> void:
	Globals.main.load_level(Globals.MAIN_MENU_PATH)
