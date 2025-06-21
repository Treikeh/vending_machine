class_name InteractArea3D
extends Area3D


enum TYPE {
	NONE,
	BUTTON,
	PICK_UP,
}

signal interacted(instigator: Node3D)


#@export var prompt: String = "Interact"
@export var prompt: TYPE = TYPE.BUTTON


func interact(instigator: Node3D) -> void:
	interacted.emit(instigator)
