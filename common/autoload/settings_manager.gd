extends Node


signal input_settings_changed
signal video_settings_changed
signal audio_settings_changed


enum DISPLAY_MODE {
	FULLSCREEN,
	BORDERLESS_FULLSCREEN,
	WINDOWED,
	BORDERLESS_WINDOWED,
}


const USER_PATH: String = "user://settings.ini"
const DEBUG_PATH: String = "res://debug/settings.ini"
const DEFAULTS: Dictionary = {
	"AUDIO": {
		"MASTER_VOLUME": 0.75,
	},
	"INPUT": {
		"CAMERA_SENSITIVITY": 0.1,
		#"KEYBINDINGS": InputMap.get_actions(),
	},
	"VIDEO": {
		"DISPLAY_MODE": DISPLAY_MODE.BORDERLESS_FULLSCREEN,
		"VSYNC_MODE": DisplayServer.VSYNC_ENABLED,
		"MAX_FPS": 60.0,
		"FIELD_OF_VIEW": 90.0,
	},
}

const INPUT_ACTIONS: Dictionary = {
	"interact": "Interact",
	"use_item": "Use item",
	"throw_item": "Throw item",
}


var _config_file: ConfigFile = ConfigFile.new()

@onready var _config_path: String = DEBUG_PATH if OS.is_debug_build() else USER_PATH


func _ready() -> void:
	if not FileAccess.file_exists(_config_path):
		# Create new config file with all the settings.
		#NOTE: Remember to delete settings.ini file when adding/removing elements
		_config_file.set_value("AUDIO", "master_volume", DEFAULTS.AUDIO.MASTER_VOLUME)
		
		_config_file.set_value("INPUT", "camera_sensitivity", DEFAULTS.INPUT.CAMERA_SENSITIVITY)
		#_config_file.set_value("INPUT", "keybindings", InputMap.)
		
		_config_file.set_value("VIDEO", "display_mode", DEFAULTS.VIDEO.DISPLAY_MODE)
		_config_file.set_value("VIDEO", "vsync_mode", DEFAULTS.VIDEO.VSYNC_MODE)
		_config_file.set_value("VIDEO", "max_fps", DEFAULTS.VIDEO.MAX_FPS)
		_config_file.set_value("VIDEO", "field_of_view", DEFAULTS.VIDEO.FIELD_OF_VIEW)
		
		save_settings()
	else:
		# Load config file
		_config_file.load(_config_path)
	
	# Apply settings when the game starts
	apply_audio_settings()
	apply_video_settings()


func save_settings() -> void:
	_config_file.save(_config_path)


#region Audio

func set_audio_setting(key: String, value) -> void:
	_config_file.set_value("AUDIO", key, value)
	audio_settings_changed.emit()


func load_audio_settings() -> Dictionary:
	var audio_settings: Dictionary = {}
	for key in _config_file.get_section_keys("AUDIO"):
		audio_settings[key] = _config_file.get_value("AUDIO", key)
	return audio_settings


func apply_audio_settings() -> void:
	var audio_settings: Dictionary = load_audio_settings()
	if audio_settings.is_empty():
		return
	
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), audio_settings.master_volume)

#endregion


#region Inputs

func set_input_setting(key: String, value) -> void:
	_config_file.set_value("INPUT", key, value)
	input_settings_changed.emit()


func load_input_settings() -> Dictionary:
	var input_settings: Dictionary = {}
	for key in _config_file.get_section_keys("INPUT"):
		input_settings[key] = _config_file.get_value("INPUT", key)
	return input_settings

#endregion


#region Video

func set_video_setting(key: String, value) -> void:
	_config_file.set_value("VIDEO", key, value)
	video_settings_changed.emit()


func load_video_settings() -> Dictionary:
	var video_settings: Dictionary = {}
	for key in _config_file.get_section_keys("VIDEO"):
		video_settings[key] = _config_file.get_value("VIDEO", key)
	return video_settings


func apply_video_settings() -> void:
	var video_settings: Dictionary = load_video_settings()
	if video_settings.is_empty():
		return
	
	Engine.max_fps = int(video_settings.max_fps)
	set_display_mode(video_settings.display_mode)


func set_display_mode(display_mode: DISPLAY_MODE) -> void:
	match display_mode:
		DISPLAY_MODE.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DISPLAY_MODE.BORDERLESS_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DISPLAY_MODE.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DISPLAY_MODE.BORDERLESS_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func set_vsync_mode(vsync_mode: DisplayServer.VSyncMode) -> void:
	DisplayServer.window_set_vsync_mode(vsync_mode)

#endregion
