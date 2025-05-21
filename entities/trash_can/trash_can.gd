extends Node3D


@export var static_body: StaticBody3D


func _ready() -> void:
	static_body.hide()
	static_body.process_mode = Node.PROCESS_MODE_DISABLED


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if not static_body.visible:
		static_body.show()
		static_body.process_mode = Node.PROCESS_MODE_INHERIT


func _on_destroy_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("bottle"):
		body.queue_free()
