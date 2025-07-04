extends Control
# Credits: StayAtHomeDev - https://www.youtube.com/watch?v=QKAuacUG0y4


@export var _fade_in_time: float = 1.0
@export var _fade_out_time: float = 1.0
## How long a splash screen is visible on screen
@export var _pause_time: float = 1.5
## How much time is between different splash screens.
## NOTE: This is is used before and after the the fading in/out the splash screen so the real
## duration == _interval_time * 2
@export var _interval_time: float = 0.5

var _splash_screens: Array[Node] = []

@onready var _splash_screen_container: CenterContainer = %SplashScreenContainer


func _ready() -> void:
	_get_screens()
	_fade_between_screens()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_load_main_menu()


func _get_screens() -> void:
	_splash_screens = _splash_screen_container.get_children()
	for screen: Control in _splash_screens:
		screen.modulate = Color.TRANSPARENT


func _fade_between_screens() -> void:
	for screen: Control in _splash_screens:
		var tween = create_tween()
		tween.tween_interval(_interval_time)
		tween.tween_property(screen, "modulate", Color.WHITE, _fade_in_time)
		tween.tween_interval(_pause_time)
		tween.tween_property(screen, "modulate", Color.TRANSPARENT, _fade_out_time)
		tween.tween_interval(_interval_time)
		await tween.finished
	_load_main_menu()


func _load_main_menu() -> void:
	Globals.main.load_level(Globals.MAIN_MENU_PATH)
