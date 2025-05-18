extends Node


func _physics_process(_delta: float) -> void:
	$GUI/FpsLabel.text = "FPS: %s" % Engine.get_frames_per_second()
