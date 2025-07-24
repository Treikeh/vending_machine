extends Node
## This script is responsible for saving/loaidng save data form a file and to store that data so
## other scenes can use it.


const USER_PATH: String = "user://savegame.save"
const DEBUG_PATH: String = "res://debug/savegame.ini"


var _file_access: FileAccess
var _save_data: Dictionary

@onready var _save_path: String = DEBUG_PATH if OS.is_debug_build() else USER_PATH


func _ready() -> void:
	_load_data_from_file()


func _exit_tree() -> void:
	return
	_save_data_to_file()


func add_save_data(key:String, data: Dictionary) -> void:
	_save_data[key] = data


func get_save_data(key: String) -> Dictionary:
	return _save_data[key] if _save_data.has(key) else {}


func _save_data_to_file() -> void:
	# Create/open a file to write to
	_file_access = FileAccess.open(_save_path, FileAccess.WRITE)
	# Turn _save_data dict into a string and save it on the save file
	_file_access.store_string(JSON.stringify(_save_data, "\t"))
	_file_access.close()


func _load_data_from_file() -> void:
	# Check if save file exists
	if FileAccess.file_exists(_save_path):
		# Open save file so that data can be read from it
		_file_access = FileAccess.open(_save_path, FileAccess.READ)
		# Parse the save file and set the _save_dict to the result
		_save_data = JSON.parse_string(_file_access.get_as_text())
		_file_access.close()
