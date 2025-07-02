extends Control


@export var animation_player: AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _input(event: InputEvent) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
