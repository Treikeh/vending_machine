extends Control


@export var animation_player: AnimationPlayer
var skipped: bool = false


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Globals.main.load_level("uid://wwxe07fon8hy")
		skipped = true


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if !skipped:
		Globals.main.load_level("uid://wwxe07fon8hy")
