extends Control


@export var _interact_icon_sprite_frames: SpriteFrames

var _pause_menu: Control

@onready var _fps_label: Label = %FpsLabel
@onready var _crosshair_texture: TextureRect = %CrosshairTexture


func _ready() -> void:
	Globals.interact_icon_updated.connect(_on_interact_icon_updated)
	# Throw charge bar
	_throw_charge_bar.modulate = Color.TRANSPARENT
	_throw_charge_bar_fade_delay.timeout.connect(_on_throw_charge_bar_fade_delay_timeout)
	Globals.throw_charge_updated.connect(_on_throw_charge_updated)
	Globals.throw_charge_stopped.connect(_on_throw_charge_stopped)


func _unhandled_input(event: InputEvent) -> void:
	# Pause game and show pause menu when pressing esc
	if event.is_action_pressed("ui_cancel") and !_pause_menu:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# Spawn pause menu
		_pause_menu = GuiManager.load_menu("uid://ca47ihv0ka8al")
		_pause_menu.tree_exiting.connect(_on_pause_menu_tree_exiting)


func _on_pause_menu_tree_exiting() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	show()


func _physics_process(_delta: float) -> void:
	_fps_label.text = "FPS: %s" % Engine.get_frames_per_second()


func _on_interact_icon_updated(prompt: int) -> void:
	_crosshair_texture.texture = _interact_icon_sprite_frames.get_frame_texture("default", prompt)



#region Throw charge bar

@export_group("Throw charge bar")
@export var _throw_charge_bar_fade_duration: float = 0.75
#@export var throw_charge_bar: TextureProgressBar
#@export var throw_charge_bar_fade_delay: Timer

var _throw_bar_fade_tween: Tween

@onready var _throw_charge_bar: TextureProgressBar = %ThrowChargeBar
@onready var _throw_charge_bar_fade_delay: Timer = %ThrowChargeBarFadeDelay



func _on_throw_charge_updated(value: float) -> void:
	_throw_charge_bar.modulate = Color.WHITE
	_throw_charge_bar.value = value
	if !_throw_charge_bar_fade_delay.is_stopped():
		_throw_charge_bar_fade_delay.stop()


func _on_throw_charge_stopped() -> void:
	if _throw_bar_fade_tween:
		_throw_bar_fade_tween.kill()

	_throw_charge_bar_fade_delay.start(0.0)


func _on_throw_charge_bar_fade_delay_timeout() -> void:
	_throw_bar_fade_tween = create_tween()
	_throw_bar_fade_tween.tween_property(_throw_charge_bar, "modulate", Color.TRANSPARENT, _throw_charge_bar_fade_duration)

#endregion
