extends Node


func _ready() -> void:
	EventBus.interact_icon_updated.connect(_on_interact_icon_updated)
	EventBus.throw_charge_bar_updated.connect(_on_throw_charge_bar_updated)


func _physics_process(_delta: float) -> void:
	$GUI/FpsLabel.text = "FPS: %s" % Engine.get_frames_per_second()


func _on_interact_icon_updated(prompt: String) -> void:
	print(prompt)


func _on_throw_charge_bar_updated(value: float) -> void:
	$GUI/ThrowChargeBar.value = value
