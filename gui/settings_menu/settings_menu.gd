extends Control


func _ready() -> void:
	_set_up_audio_settings()
	_set_up_input_settings()
	_set_up_video_settings()
	
	# Connect signals
	%VolumeSlider.value_changed.connect(_on_volume_slider_value_changed)
	%SensitivitySlider.value_changed.connect(_on_sensitivity_slider_value_changed)
	%DisplayModeOptionsButton.item_selected.connect(_on_display_mode_options_button_item_selected)
	%ApplyButton.pressed.connect(_on_apply_button_pressed)
	%BackButton.pressed.connect(_on_back_button_pressed)


func _on_apply_button_pressed() -> void:
	# Save new settings
	SettingsManager.set_audio_setting("master_volume", new_audio_settings.master_volume)
	SettingsManager.set_input_setting("camera_sensitivity", new_input_settings.camera_sensitivity)
	SettingsManager.set_video_setting("display_mode", new_video_settings.display_mode)
	SettingsManager.save_settings()
	# Reset apply button
	old_audio_settings = new_audio_settings.duplicate()
	old_input_settings = new_input_settings.duplicate()
	old_video_settings = new_video_settings.duplicate()
	%ApplyButton.disabled = true


func _on_back_button_pressed() -> void:
	# Actually apply the settings when closing the menu. If the new settings aren't applied with ->
	# <- the apply button then the new settings are discarded
	SettingsManager.apply_audio_settings()
	SettingsManager.apply_video_settings()
	queue_free()


func _are_new_and_old_settings_matching() -> bool:
	var audio: bool = new_audio_settings == old_audio_settings
	var input: bool = new_input_settings == old_input_settings
	var video: bool = new_video_settings == old_video_settings
	return (video and input and audio)


#region Audio settings

# The settings when the menu is opened
var old_audio_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_audio_settings: Dictionary


func _set_up_audio_settings() -> void:
	var audio_settings: Dictionary = SettingsManager.load_audio_settings()
	old_audio_settings = audio_settings.duplicate()
	new_audio_settings = audio_settings.duplicate()
	%VolumeSlider.value = audio_settings.master_volume


func _on_volume_slider_value_changed(value: float) -> void:
	new_audio_settings.master_volume = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	
	# Disable the apply button if the new and old values aren't matching
	%ApplyButton.disabled = _are_new_and_old_settings_matching()

#endregion


#region Input settings

# The settings when the menu is opened
var old_input_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_input_settings: Dictionary


func _set_up_input_settings() -> void:
	# Load input settings when opening the menu
	var input_settings: Dictionary = SettingsManager.load_input_settings()
	old_input_settings = input_settings.duplicate()
	new_input_settings = input_settings.duplicate()
	%SensitivitySlider.value = input_settings.camera_sensitivity


func _on_sensitivity_slider_value_changed(value: float) -> void:
	new_input_settings.camera_sensitivity = value
	
	# Disable the apply button if the new and old values aren't matching
	%ApplyButton.disabled = _are_new_and_old_settings_matching()

#endregion


#region Video settings

# The settings when the menu is opened
var old_video_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_video_settings: Dictionary


func _set_up_video_settings() -> void:
	var video_settings: Dictionary = SettingsManager.load_video_settings()
	#NOTE: Have to duplicate the dict to properly compare them.
	# If i don't they will always have the same values
	old_video_settings = video_settings.duplicate()
	new_video_settings = video_settings.duplicate()
	%DisplayModeOptionsButton.selected = video_settings.display_mode


func _on_display_mode_options_button_item_selected(index: int) -> void:
	new_video_settings.display_mode = index
	SettingsManager.set_display_mode(index)
	
	# Disable the apply button if the new and old values aren't matching
	%ApplyButton.disabled = _are_new_and_old_settings_matching()

#endregion
