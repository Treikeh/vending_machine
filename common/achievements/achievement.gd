extends Resource
class_name Achievement


@export var name: String = "Name"
@export var description: String = "Do X"
@export var max_points: int = 1
@export var icon: Texture2D = preload("res://icon.png")

var current_points: int = 0
var _completed: bool = false


func add_points(points: int = 1) -> void:
	if _completed:
		return
	
	current_points += points
	if current_points >= max_points:
		_completed = true
		AchievementsManager.achievement_completed.emit(self)


func is_completed() -> bool:
	return _completed


#region Save/Load

func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"points": current_points,
		"completed": _completed,
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		current_points = data.points
		_completed = data.completed

#endregion
