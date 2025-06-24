class_name LoadingScreen
extends PanelContainer


signal fully_visible
signal fully_hidden

@export var fade_duration: float = 1.0
@export var progress_bar: ProgressBar


func fade_inn() -> void:
	show()
	modulate = Color.TRANSPARENT
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color.WHITE, fade_duration)
	
	await fade_tween.finished
	fully_visible.emit()


func update_progress(new_value: float) -> void:
	progress_bar.value = new_value


func fade_out() -> void:
	modulate = Color.WHITE
	
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	
	await fade_tween.finished
	fully_hidden.emit()
	hide()
