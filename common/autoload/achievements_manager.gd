extends Node

@warning_ignore("unused_signal")
signal achievement_completed(achievement: Achievement)


const FILE_NAME: String = "achievements.ini"

var _achievements: Dictionary[String, Achievement] = {
	"buy_everything": preload("uid://bnk78nq5t4hpx"),
	"basketball": preload("uid://cw8em4x3l2gxj"),
}

@onready var _file_path: String = Utility.get_data_dir_path() + FILE_NAME


func _ready() -> void:
	_load_achievements_data(Utility.load_data_from_file(_file_path))


func _exit_tree() -> void:
	Utility.save_data_to_file(_file_path, _get_achievements_data())


func add_points_to_achievement(achievement: String, points: int = 1) -> void:
	_achievements[achievement].add_points(points)


func item_bought(item_code: String) -> void:
	var buy_everything_achievement: BuyEverythingAchievement = _achievements["buy_everything"]
	buy_everything_achievement.item_bought(item_code)


#region Save/Load Data

func _get_achievements_data() -> Dictionary:
	var data: Dictionary = {}
	for achievement: String in _achievements:
		data[achievement] = _achievements[achievement].get_save_data()
	return data


func _load_achievements_data(data: Dictionary) -> void:
	if not data.is_empty():
		for achievement: String in _achievements:
			_achievements[achievement].load_save_data(data[achievement])

#endregion
