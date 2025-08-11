extends Node

signal input_settings_changed
signal video_settings_changed
signal audio_settings_changed

@warning_ignore("unused_signal")
signal fov_updated(value: float)


enum DISPLAY_MODE {
	FULLSCREEN,
	BORDERLESS_FULLSCREEN,
	WINDOWED,
	BORDERLESS_WINDOWED,
}


const FILE_NAME: String = "settings.ini"
const DEFAULTS: Dictionary = {
	"AUDIO": {
		"MASTER_VOLUME": 0.75,
	},
	"INPUT": {
		"CAMERA_SENSITIVITY": 0.1,
		"KEYBINDINGS": {},
	},
	"VIDEO": {
		"DISPLAY_MODE": DISPLAY_MODE.BORDERLESS_FULLSCREEN,
		"VSYNC_MODE": DisplayServer.VSYNC_ENABLED,
		"MAX_FPS": 60.0,
		"FIELD_OF_VIEW": 90.0,
	},
}


var _config_file: ConfigFile = ConfigFile.new()

@onready var _config_path: String = Utility.get_data_dir_path() + FILE_NAME


func _ready() -> void:
	if not FileAccess.file_exists(_config_path):
		# Create new config file with all the settings.
		#NOTE: Remember to delete settings.ini file when adding/removing elements
		for section: String in DEFAULTS:
			for setting: String in DEFAULTS[section]:
				_config_file.set_value(section, setting.to_lower(), DEFAULTS[section][setting])
		
		save_settings()
	else:
		# Load config file
		_config_file.load(_config_path)
	
	# Apply settings when the game starts
	apply_audio_settings()
	apply_input_settings()
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

const REMAPPABLE_INPUT_ACTIONS: Dictionary[String, String] = {
	"move_f": "Walk forward",
	"move_b": "Walk backward",
	"move_l": "Strafe left",
	"move_r": "Strafe right",
	"jump": "Jump",
	"interact": "Interact",
	"use_item": "Use item",
	"throw_item": "Throw item",
}


func set_input_setting(key: String, value) -> void:
	_config_file.set_value("INPUT", key, value)
	input_settings_changed.emit()


func load_input_settings() -> Dictionary:
	var input_settings: Dictionary = {}
	for key in _config_file.get_section_keys("INPUT"):
		input_settings[key] = _config_file.get_value("INPUT", key)
	return input_settings


func apply_input_settings() -> void:
	var input_settings: Dictionary = load_input_settings()
	if input_settings.is_empty():
		return
	
	# Apply changes to keybindings
	var keybindings: Dictionary = input_settings.keybindings
	for action: String in keybindings:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

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
	
	set_display_mode(video_settings.display_mode)
	set_vsync_mode(video_settings.vsync_mode)
	Engine.max_fps = int(video_settings.max_fps)


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
