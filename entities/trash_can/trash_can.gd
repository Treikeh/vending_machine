extends Node3D


## How many items the player needs to buy before the trash can can become visible
@export var become_visible_buy_count: int = 5
@export var static_body: StaticBody3D

var buy_count: int = 0


func _ready() -> void:
	# Hide and disable static body when the game starts
	static_body.hide()
	static_body.process_mode = Node.PROCESS_MODE_DISABLED
	# Connect event
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)


func _on_vending_machine_code_submitted(_code: String, is_valid: bool) -> void:
	if is_valid:
		buy_count += 1


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if not static_body.visible and buy_count >= become_visible_buy_count:
		static_body.show()
		static_body.process_mode = Node.PROCESS_MODE_INHERIT


func _on_destroy_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("bottle"):
		body.queue_free()
