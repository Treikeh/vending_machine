extends PanelContainer


const MOVE_TIME: float = 1.0

@export var _icon: TextureRect
@export var _name_label: Label
@export var _description_label: Label
@export var _timer: Timer
@export var _vfx: GPUParticles2D

@onready var _screen_bottom: float = get_viewport_rect().size.y
@onready var _screen_center: Vector2 = (get_viewport_rect().size / 2) - (size / 2)


func with_data(achievement: Achievement) -> Control:
	_icon.texture = achievement.icon
	_name_label.text = achievement.name
	_description_label.text = achievement.description
	return self


func _ready() -> void:
	# Set start position to the bottom center of the screen
	position.x = _screen_center.x
	position.y = _screen_bottom
	# Move node upwards to the center of the screen
	var move_tween: Tween = create_tween()
	move_tween.tween_property(self, "position:y", _screen_center.y, MOVE_TIME)
	await move_tween.finished
	#TODO: Spawn particle effects and play sound
	_vfx.emitting = true
	_timer.start()


func _on_timer_timeout() -> void:
	# Move node to the bottom of the screen
	var move_tween: Tween = create_tween()
	move_tween.tween_property(self, "position:y", _screen_bottom, MOVE_TIME)
	move_tween.tween_interval(MOVE_TIME)
	await move_tween.finished
	queue_free()
