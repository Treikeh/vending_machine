extends Node3D


func _ready() -> void:
	# Connect signals
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)


func _on_vending_machine_code_submitted(code: String, _valid: bool) -> void:
	match code:
		"1996":
			pass
