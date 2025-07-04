class_name LoadingScreen
extends CanvasLayer


#TODO: Hide the progress bar and label until a few seconds has passed. I think it's ugly when ->
# <- they're visible and the loading screen takes less than 1 second to load the scene


signal fully_visible
signal fully_hidden

@export var fade_duration: float = 1.0
@export var panel: Control
@export var progress_bar: ProgressBar


func _ready() -> void:
	hide()
	progress_bar.value = 0


func fade_inn() -> void:
	show()
	panel.modulate = Color.TRANSPARENT
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(panel, "modulate", Color.WHITE, fade_duration)
	
	await fade_tween.finished
	fully_visible.emit()


func update_progress(new_value: float) -> void:
	progress_bar.value = new_value


func fade_out() -> void:
	panel.modulate = Color.WHITE
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(panel, "modulate", Color.TRANSPARENT, fade_duration)
	
	await fade_tween.finished
	fully_hidden.emit()
	hide()
