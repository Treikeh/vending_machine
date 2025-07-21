extends Node
#TODO: Encode save data to hex or something (Not necessary, but might be a good idea)
#TODO: Find a way to save items that have been spawned into levels

# Saving/Loading level data to/from file
const USER_PATH: String = "user://savegame.save"
const DEBUG_PATH: String = "res://debug/savegame.ini"


var _save_data: Dictionary

@onready var _save_path: String = DEBUG_PATH if OS.is_debug_build() else USER_PATH


func _ready() -> void:
	# Load data when game starts
	_load_data_from_file()
	#tree_exiting.connect(_on_tree_exiting)


func _on_tree_exiting() -> void:
	# Save data when exiting the game
	_save_data_to_file()


func add_save_data(key:String, data: Dictionary) -> void:
	_save_data[key] = data


func get_save_data(key: String) -> Dictionary:
	return _save_data[key] if _save_data.has(key) else {}


func _save_data_to_file() -> void:
	# Create/open a file to write to
	var save_file := FileAccess.open(_save_path, FileAccess.WRITE)
	# Turn save data into a string
	var data_string: String = JSON.stringify(_save_data, "\t")
	# Save data to file
	save_file.store_string(data_string)


func _load_data_from_file() -> void:
	# Check if save file exists
	if not FileAccess.file_exists(_save_path):
		return
	
	# Turn text from save file into a dictionary using JSON
	var save_file := FileAccess.open(_save_path, FileAccess.READ)
	var json := JSON.new()
	var parse_result: Error = json.parse(save_file.get_as_text())
	if not parse_result == OK:
		print("JSON Parse Error: %s, at line %s" % json.get_error_message(), json.get_error_line())
		return
	
	# Set save data
	_save_data = json.data
