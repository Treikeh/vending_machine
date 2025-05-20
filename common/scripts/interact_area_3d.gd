class_name InteractArea3D
extends Area3D


signal interacted


@export var prompt: String = "Interact"


func interact() -> void:
	interacted.emit()
