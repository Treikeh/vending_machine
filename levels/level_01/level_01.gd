extends Node3D


@export var monument: Node3D


func _ready() -> void:
	# Connect signals
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)
	
	# Disable monument at the start of the game
	monument.hide()
	monument.process_mode = Node.PROCESS_MODE_DISABLED


func _on_vending_machine_code_submitted(code: String, _valid: bool) -> void:
	match code:
		"1996":
			monument.show()
			monument.process_mode = Node.PROCESS_MODE_INHERIT


func _on_monument_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.queue_free()
