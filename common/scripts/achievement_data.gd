extends Resource
class_name AchievementData


@export var name: String = "Name"
@export var requirement: String = "Do X"
@export var max_points: int = 1
@export var icon: Texture2D

var current_points: int = 0
var completed: bool = false


func add_points(points: int = 1) -> void:
	if completed:
		return
	
	current_points += points
	if current_points >= max_points:
		completed = true
		Globals.achievement_completed.emit(self)
	# Add info about achievement to save data
	SaveManager.add_save_data(resource_path, get_save_data())


func get_save_data() -> Dictionary:
	var data: Dictionary = {
		"points": current_points,
		"completed": completed,
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		current_points = data.points
		completed = data.completed
