class_name LoadingScreen
extends CanvasLayer


signal fully_visible
signal fully_hidden

@export var fade_duration: float = 1.0

@onready var _ui: Control = %Ui
@onready var _progress_container: Control = %ProgressContainer
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _show_progress_delay: Timer = %ShowProgressDelay


func _ready() -> void:
	hide()
	_show_progress_delay.timeout.connect(_on_show_progress_delay_timeout)


func fade_in() -> void:
	show()
	# Reset loading screen when starting the fade in
	_ui.modulate = Color.TRANSPARENT
	_progress_bar.value = 0
	_progress_container.modulate = Color.TRANSPARENT
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(_ui, "modulate", Color.WHITE, fade_duration)
	
	await fade_tween.finished
	_show_progress_delay.start(0.0)
	fully_visible.emit()


func update_progress(new_value: float) -> void:
	_progress_bar.value = new_value


func fade_out() -> void:
	_ui.modulate = Color.WHITE
	_show_progress_delay.stop()
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(_ui, "modulate", Color.TRANSPARENT, fade_duration)
	
	await fade_tween.finished
	fully_hidden.emit()
	hide()


func _on_show_progress_delay_timeout() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(_progress_container, "modulate", Color.WHITE, fade_duration)
