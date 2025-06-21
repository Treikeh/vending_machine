extends Control


@export var fps_label: Label
@export var crosshair_texture: TextureRect
@export var interact_icon_sprite_frames: SpriteFrames


func _ready() -> void:
	EventBus.interact_icon_updated.connect(_on_interact_icon_updated)
	# Throw charge bar
	throw_charge_bar.modulate = Color.TRANSPARENT
	EventBus.throw_charge_updated.connect(_on_throw_charge_updated)
	EventBus.throw_charge_stopped.connect(_on_throw_charge_stopped)


func _physics_process(_delta: float) -> void:
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


func _on_interact_icon_updated(prompt: int) -> void:
	crosshair_texture.texture = interact_icon_sprite_frames.get_frame_texture("default", prompt)



#region Throw charge bar

@export_group("Throw charge bar")
@export var throw_charge_bar_fade_duration: float = 0.75
@export var throw_charge_bar: TextureProgressBar
@export var throw_charge_bar_fade_delay: Timer

var throw_bar_fade_tween: Tween


func _on_throw_charge_updated(value: float) -> void:
	throw_charge_bar.modulate = Color.WHITE
	throw_charge_bar.value = value
	if !throw_charge_bar_fade_delay.is_stopped():
		throw_charge_bar_fade_delay.stop()


func _on_throw_charge_stopped() -> void:
	if throw_bar_fade_tween:
		throw_bar_fade_tween.kill()

	throw_charge_bar_fade_delay.start(0.0)


func _on_throw_charge_bar_fade_delay_timeout() -> void:
	throw_bar_fade_tween = create_tween()
	throw_bar_fade_tween.tween_property(throw_charge_bar, "modulate", Color.TRANSPARENT, throw_charge_bar_fade_duration)

#endregion
