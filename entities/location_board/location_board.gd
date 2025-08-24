extends RigidBody3D


func _ready() -> void:
	AchievementsManager.achievement_completed.connect(_on_achievement_completed)
	
	for achievement_name: String in AchievementsManager._achievements:
		var achievement: Achievement = AchievementsManager._achievements[achievement_name]
		if achievement.is_completed():
			var achievement_showcase: Control = ACHIEVEMENTS_SHOWCASE_SCENE.instantiate()
			achievement_showcase.load_achievement_data(achievement)
			_achievements_container.add_child(achievement_showcase)


#region Locations

@export_group("Locations")
@export var _locations_viewport: SubViewport

#endregion



#region Achievements

const ACHIEVEMENTS_SHOWCASE_SCENE: PackedScene = preload("uid://d08couw14yxhv")

@export_group("Achievements")
@export var _achievements_viewport: SubViewport
@export var _achievements_container: Container


func _on_achievement_completed(achievement: Achievement) -> void:
	var achievement_showcase: Control = ACHIEVEMENTS_SHOWCASE_SCENE.instantiate()
	achievement_showcase.load_achievement_data(achievement)
	_achievements_container.add_child(achievement_showcase)

#endregion



#region Save/Load

func get_save_data() -> Dictionary:
	return {}


func load_save_data(data: Dictionary) -> void:
	pass

#endregion
