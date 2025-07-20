extends Control


@onready var _apply_button: Button = %ApplyButton


func _ready() -> void:
	_setup_audio_settings()
	_setup_input_settings()
	_setup_video_settings()
	_setup_keybinding()
	_setup_confirm_pop_up()
	
	## Connect signals
	_apply_button.pressed.connect(_on_apply_button_pressed)
	%BackButton.pressed.connect(_on_back_button_pressed)
	%DefaultsButton.pressed.connect(_on_defaults_button_pressed)


func _on_apply_button_pressed() -> void:
	# Save new settings
	SettingsManager.set_audio_setting("master_volume", new_audio_settings.master_volume)
	SettingsManager.set_input_setting("camera_sensitivity", new_input_settings.camera_sensitivity)
	SettingsManager.set_video_setting("display_mode", new_video_settings.display_mode)
	SettingsManager.set_video_setting("vsync_mode", new_video_settings.vsync_mode)
	SettingsManager.set_video_setting("field_of_view", new_video_settings.field_of_view)
	SettingsManager.set_video_setting("max_fps", new_video_settings.max_fps)
	SettingsManager.save_settings()
	# Reset apply button
	old_audio_settings = new_audio_settings.duplicate()
	old_input_settings = new_input_settings.duplicate()
	old_video_settings = new_video_settings.duplicate()
	_apply_button.disabled = true


func _on_back_button_pressed() -> void:
	if !_are_new_and_old_settings_matching():
		_confirm_pop_up.show()
		return
	
	_close_settings_menu()


func _on_defaults_button_pressed() -> void:
	var defaults: Dictionary = SettingsManager.DEFAULTS
	_on_master_volume_changed(defaults.AUDIO.MASTER_VOLUME)
	_on_sensitivity_changed(defaults.INPUT.CAMERA_SENSITIVITY)
	_on_display_mode_changed(defaults.VIDEO.DISPLAY_MODE)
	_on_vsync_mode_changed(defaults.VIDEO.VSYNC_MODE)
	_on_fps_changed(defaults.VIDEO.MAX_FPS)
	_on_field_of_view_changed(defaults.VIDEO.FIELD_OF_VIEW)


func _are_new_and_old_settings_matching() -> bool:
	var audio: bool = new_audio_settings == old_audio_settings
	var input: bool = new_input_settings == old_input_settings
	var video: bool = new_video_settings == old_video_settings
	return (video and input and audio)


func _close_settings_menu() -> void:
	# Actually apply the settings when closing the menu. If the new settings aren't applied with ->
	# <- the apply button then the new settings are discarded
	SettingsManager.apply_audio_settings()
	SettingsManager.apply_video_settings()
	queue_free()



#region Confirm pop up

@onready var _confirm_pop_up: PanelContainer = %ConfirmPopUp


func _setup_confirm_pop_up() -> void:
	_confirm_pop_up.hide()
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%DiscardButton.pressed.connect(_on_discard_button_pressed)


func _on_save_button_pressed() -> void:
	_on_apply_button_pressed()
	_close_settings_menu()


func _on_discard_button_pressed() -> void:
	_close_settings_menu()

#endregion



#region Audio settings

@onready var _master_volume_slider: HSlider = %MasterVolumeSlider
@onready var _master_volume_spin_box: SpinBox = %MasterVolumeSpinBox


# The settings when the menu is opened
var old_audio_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_audio_settings: Dictionary


func _setup_audio_settings() -> void:
	var audio_settings: Dictionary = SettingsManager.load_audio_settings()
	old_audio_settings = audio_settings.duplicate()
	new_audio_settings = audio_settings.duplicate()
	
	# Master volume
	_master_volume_slider.value = audio_settings.master_volume
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	
	_master_volume_spin_box.value = audio_settings.master_volume
	_master_volume_spin_box.value_changed.connect(_on_master_volume_changed)


func _on_master_volume_changed(value: float) -> void:
	new_audio_settings.master_volume = value
	_master_volume_slider.value = value
	_master_volume_spin_box.value = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion



#region Input settings

# The settings when the menu is opened
var old_input_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_input_settings: Dictionary

@onready var _sensitivity_slider: HSlider = %SensitivitySlider
@onready var _sensitivity_spin_box: SpinBox = %SensitivitySpinBox


func _setup_input_settings() -> void:
	# Load input settings when opening the menu
	var input_settings: Dictionary = SettingsManager.load_input_settings()
	old_input_settings = input_settings.duplicate()
	new_input_settings = input_settings.duplicate()
	
	# Camera sensitivity
	_sensitivity_slider.value = input_settings.camera_sensitivity
	_sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	
	_sensitivity_spin_box.value = input_settings.camera_sensitivity
	_sensitivity_spin_box.value_changed.connect(_on_sensitivity_changed)


func _on_sensitivity_changed(value: float) -> void:
	new_input_settings.camera_sensitivity = value
	_sensitivity_slider.value = value
	_sensitivity_spin_box.value = value
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion



#region Video settings

# The settings when the menu is opened
var old_video_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var new_video_settings: Dictionary

@onready var _display_mode_options_button: OptionButton = %DisplayModeOptionsButton
@onready var _vsync_mode_options_button: OptionButton = %VsyncModeOptionsButton
@onready var _fps_slider: HSlider = %FpsSlider
@onready var _fps_spin_box: SpinBox = %FpsSpinBox
@onready var _fov_slider: HSlider = %FovSlider
@onready var _fov_spin_box: SpinBox = %FovSpinBox
@onready var _camera_3d: Camera3D = %Camera3D


func _setup_video_settings() -> void:
	var video_settings: Dictionary = SettingsManager.load_video_settings()
	old_video_settings = video_settings.duplicate()
	new_video_settings = video_settings.duplicate()
	
	# Display mode
	_display_mode_options_button.selected = video_settings.display_mode
	_display_mode_options_button.item_selected.connect(_on_display_mode_changed)
	
	#VSync
	_vsync_mode_options_button.selected = video_settings.vsync_mode
	_vsync_mode_options_button.item_selected.connect(_on_vsync_mode_changed)
	
	# Frame rate
	var vsync_enabled: bool = _vsync_mode_options_button.selected == DisplayServer.VSYNC_ENABLED
	_fps_slider.editable = not vsync_enabled
	_fps_slider.value = video_settings.max_fps
	_fps_slider.value_changed.connect(_on_fps_changed)
	
	_fps_spin_box.editable = not vsync_enabled
	_fps_spin_box.value = video_settings.max_fps
	_fps_spin_box.value_changed.connect(_on_fps_changed)
	
	# Field of view
	_camera_3d.fov = video_settings.field_of_view
	_fov_slider.value = video_settings.field_of_view
	_fov_slider.value_changed.connect(_on_field_of_view_changed)
	
	_fov_spin_box.value = video_settings.field_of_view
	_fov_spin_box.value_changed.connect(_on_field_of_view_changed)


func _on_display_mode_changed(index: int) -> void:
	new_video_settings.display_mode = index
	SettingsManager.set_display_mode(index)
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_vsync_mode_changed(index: int) -> void:
	new_video_settings.vsync_mode = index
	SettingsManager.set_vsync_mode(index as DisplayServer.VSyncMode)
	# Disable/Enable fps options if vsync is enabled
	if index == DisplayServer.VSYNC_ENABLED:
		_on_fps_changed(DisplayServer.screen_get_refresh_rate())
		_fps_slider.editable = false
		_fps_spin_box.editable = false
	else:
		_fps_slider.editable = true
		_fps_spin_box.editable = true
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_fps_changed(value: float) -> void:
	new_video_settings.max_fps = value
	_fps_slider.value = value
	_fps_spin_box.value = value
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_field_of_view_changed(value: float) -> void:
	new_video_settings.field_of_view = value
	_camera_3d.fov = value
	_fov_slider.value = value
	_fov_spin_box.value = value
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion

#region Keybinding

const _INPUT_REMAP_ENTRY_SCENE := preload("uid://bhiluyjm3vp1y")

@onready var _keybindings_container: VBoxContainer = %KeybindingsContainer


func _setup_keybinding() -> void:
	var input_actions: Dictionary = SettingsManager.INPUT_ACTIONS
	for action: String in input_actions:
		var input_entry: Control = _INPUT_REMAP_ENTRY_SCENE.instantiate()
		_keybindings_container.add_child(input_entry)
		
		input_entry.setup_scene(action)
		input_entry.set_process_input(false)

#endregion
