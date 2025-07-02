extends Node3D


## How many items the player needs to buy before the trash can can become visible
@export_range(1, 99) var become_visible_buy_count: int = 5
@export_range(1, 99) var trash_capacity: int = 5
@export var mesh: Node3D

var items_trashed: int = 0
var buy_count: int = 0


func _ready() -> void:
	# Hide and disable mesh when the game starts
	_disable_mesh()
	# Connect event from vending machine
	EventBus.vending_machine_code_submitted.connect(_on_vending_machine_code_submitted)


func _enable_mesh() -> void:
	mesh.show()
	mesh.process_mode = Node.PROCESS_MODE_INHERIT


func _disable_mesh() -> void:
	mesh.hide()
	mesh.process_mode = Node.PROCESS_MODE_DISABLED


func _on_vending_machine_code_submitted(_code: String, is_valid: bool) -> void:
	if is_valid:
		buy_count += 1


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if not mesh.visible and buy_count >= become_visible_buy_count:
		_enable_mesh()


func _on_destroy_area_body_entered(body: Node3D) -> void:
	if body.has_method("destroy_item") and items_trashed < trash_capacity:
		items_trashed += 1
		body.destroy_item(self)
