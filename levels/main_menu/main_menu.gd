extends Node3D


func _on_button_pressed() -> void:
	EventBus.start_loading_level.emit("res://levels/level_01/level_01.tscn")
	#LevelManager.start_loading_level("res://levels/level_01/level_01.tscn")
