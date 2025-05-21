class_name InteractArea3D
extends Area3D


signal interacted(instigator: Node3D)


@export var prompt: String = "Interact"


func interact(instigator: Node3D) -> void:
	interacted.emit(instigator)
