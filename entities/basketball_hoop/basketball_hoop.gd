extends Node3D


func _on_point_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("basketball"):
		AchievementsManager.add_points_to_achievement("basketball")
