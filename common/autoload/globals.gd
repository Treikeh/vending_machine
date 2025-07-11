extends Node
@warning_ignore_start("unused_signal")


# Paths I have saved because i'm too lazy to find them in the file system
const MAIN_MENU_PATH: String = "uid://wwxe07fon8hy"
const SETTINGS_MENU_PATH: String = "uid://t0lpsh2ot3se"
const CREDITS_PATH: String = "uid://dkyrn54813ilp"
const WORLD_ENV_PATH: String = "uid://4jbcov8xso67"


# System
var main: MainScene


# Player ui
signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


# Vending machine
signal vending_machine_code_submitted(code: String, is_valid: bool)


# Saving/Loading level data to/from file
const RELEASE_SAVE_FILE_PATH: String = "user://savegame.save"
const DEBUG_SAVE_FILE_PATH: String = "res://debug/savegame.ini"

var level_save_data: Dictionary

@onready var _save_file_path: String = DEBUG_SAVE_FILE_PATH if OS.is_debug_build() else RELEASE_SAVE_FILE_PATH


func save_level_data_to_file() -> void:
	# Create/open a file to write to
	var save_file := FileAccess.open(_save_file_path, FileAccess.WRITE)
	# Turn level save data into a string
	var data_string: String = JSON.stringify(level_save_data)
	# Save data to file
	save_file.store_string(data_string)


func load_level_data_from_file() -> void:
	# Check if save file exists
	if not FileAccess.file_exists(_save_file_path):
		return
	
	# Turn text from save file into a dictionary using JSON
	var save_file := FileAccess.open(_save_file_path, FileAccess.READ)
	var json := JSON.new()
	var parse_result: Error = json.parse(save_file.get_as_text())
	if not parse_result == OK:
		print("JSON Parse Error: %s, at line %s" % json.get_error_message(), json.get_error_line())
		return
	
	# Set level save data
	level_save_data = json.data


# Utility
func screen_to_world_3d_ray_cast(
		camera: Camera3D,
		ray_length: float,
		collide_with_areas: bool = false,
		collide_with_bodies: bool = true,
) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + (camera.project_ray_normal(mouse_pos) * ray_length)
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = collide_with_areas
	ray_query.collide_with_bodies = collide_with_bodies
	return space.intersect_ray(ray_query)
