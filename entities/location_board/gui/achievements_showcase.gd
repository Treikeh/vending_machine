extends PanelContainer


@export var _icon_rect: TextureRect
@export var _name_label: Label
@export var _description_label: Label


func load_achievement_data(achievement: Achievement) -> void:
	_icon_rect.texture = achievement.icon
	_name_label.text = achievement.name
	_description_label.text = achievement.description
