extends Control
#TODO: Add a check to remapping to avoid giving 2 actions the same key.


@onready var _apply_button: Button = %ApplyButton


func _ready() -> void:
	_setup_audio_settings()
	_setup_input_settings()
	_setup_video_settings()
	_setup_confirm_pop_up()
	
	## Connect signals
	_apply_button.pressed.connect(_on_apply_button_pressed)
	%BackButton.pressed.connect(_on_back_button_pressed)
	%DefaultsButton.pressed.connect(_on_defaults_button_pressed)


func _input(event: InputEvent) -> void:
	# Capture key and mouse button events when remapping a key
	if _action_to_remap != "":
		var key_press: bool = event is InputEventKey
		var mouse_button_press: bool = event is InputEventMouseButton and event.pressed
		# Stop double press
		if key_press or mouse_button_press:
			_on_input_remapped(event)
			accept_event()


func _on_apply_button_pressed() -> void:
	for setting: String in _new_audio_settings:
		SettingsManager.set_audio_setting(setting, _new_audio_settings[setting])
		
	for setting: String in _new_input_settings:
		SettingsManager.set_input_setting(setting, _new_input_settings[setting])
		
	for setting: String in _new_video_settings:
		SettingsManager.set_video_setting(setting, _new_video_settings[setting])
	
	SettingsManager.save_settings()
	
	# Reset apply button
	_old_audio_settings = _new_audio_settings.duplicate()
	_old_input_settings = _new_input_settings.duplicate(true)
	_old_video_settings = _new_video_settings.duplicate()
	_apply_button.disabled = true


func _on_back_button_pressed() -> void:
	if !_are_new_and_old_settings_matching():
		_confirm_pop_up.show()
		return
	
	_close_settings_menu()


func _close_settings_menu() -> void:
	# Actually apply the settings when closing the menu. If the new settings aren't applied with ->
	# <- the apply button then the new settings are discarded
	SettingsManager.apply_audio_settings()
	SettingsManager.apply_input_settings()
	SettingsManager.apply_video_settings()
	queue_free()


func _on_defaults_button_pressed() -> void:
	# Reset keybindings
	InputMap.load_from_project_settings()
	_new_input_settings.keybindings.clear()
	_create_keybindings()
	
	var defaults: Dictionary = SettingsManager.DEFAULTS
	_on_master_volume_changed(defaults.AUDIO.MASTER_VOLUME)
	_on_sensitivity_changed(defaults.INPUT.CAMERA_SENSITIVITY)
	_on_display_mode_changed(defaults.VIDEO.DISPLAY_MODE)
	_on_vsync_mode_changed(defaults.VIDEO.VSYNC_MODE)
	_on_fps_changed(defaults.VIDEO.MAX_FPS)
	_on_field_of_view_changed(defaults.VIDEO.FIELD_OF_VIEW)


func _are_new_and_old_settings_matching() -> bool:
	var audio: bool = _new_audio_settings == _old_audio_settings
	var input: bool = _new_input_settings == _old_input_settings
	var video: bool = _new_video_settings == _old_video_settings
	return (video and input and audio)



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
var _old_audio_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_audio_settings: Dictionary


func _setup_audio_settings() -> void:
	var audio_settings: Dictionary = SettingsManager.load_audio_settings()
	_old_audio_settings = audio_settings.duplicate()
	_new_audio_settings = audio_settings.duplicate()
	
	# Master volume
	_master_volume_slider.value = audio_settings.master_volume
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	
	_master_volume_spin_box.value = audio_settings.master_volume
	_master_volume_spin_box.value_changed.connect(_on_master_volume_changed)


func _on_master_volume_changed(value: float) -> void:
	_new_audio_settings.master_volume = value
	_master_volume_slider.value = value
	_master_volume_spin_box.value = value
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion



#region Input settings

const _INPUT_REMAP_ENTRY_SCENE := preload("uid://bhiluyjm3vp1y")

# The settings when the menu is opened
var _old_input_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_input_settings: Dictionary
# Keybindings
var _action_to_remap: String
var _button_to_remap: Button

@onready var _sensitivity_slider: HSlider = %SensitivitySlider
@onready var _sensitivity_spin_box: SpinBox = %SensitivitySpinBox
@onready var _keybindings_container: VBoxContainer = %KeybindingsContainer


func _setup_input_settings() -> void:
	# Load input settings when opening the menu
	var input_settings: Dictionary = SettingsManager.load_input_settings()
	_old_input_settings = input_settings.duplicate(true)
	_new_input_settings = input_settings.duplicate(true)
	
	# Camera sensitivity
	_sensitivity_slider.value = input_settings.camera_sensitivity
	_sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	
	_sensitivity_spin_box.value = input_settings.camera_sensitivity
	_sensitivity_spin_box.value_changed.connect(_on_sensitivity_changed)
	
	# Keybindings
	_create_keybindings()


func _on_sensitivity_changed(value: float) -> void:
	_new_input_settings.camera_sensitivity = value
	_sensitivity_slider.value = value
	_sensitivity_spin_box.value = value
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _create_keybindings() -> void:
	# Remove children of keybindings container
	for child: Control in _keybindings_container.get_children():
		_keybindings_container.remove_child(child)
		child.queue_free()
	
	# Add new children to keybindings container
	var input_actions: Dictionary = SettingsManager.REMAPPABLE_INPUT_ACTIONS
	for action: String in input_actions:
		var remap_button_callback: Callable = _on_remap_button_pressed
		var remap_entry: Control = (
			_INPUT_REMAP_ENTRY_SCENE.instantiate().with_data(action, remap_button_callback)
		)
		_keybindings_container.add_child(remap_entry)


func _on_remap_button_pressed(action: String, button: Button) -> void:
	_action_to_remap = action
	_button_to_remap = button
	_button_to_remap.text = "Press any key"


func _on_input_remapped(event: InputEvent) -> void:
	_new_input_settings.keybindings[_action_to_remap] = event
	
	_action_to_remap = ""
	_button_to_remap.text = event.as_text()
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


#endregion



#region Video settings

# The settings when the menu is opened
var _old_video_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_video_settings: Dictionary

@onready var _display_mode_options_button: OptionButton = %DisplayModeOptionsButton
@onready var _vsync_mode_options_button: OptionButton = %VsyncModeOptionsButton
@onready var _fps_slider: HSlider = %FpsSlider
@onready var _fps_spin_box: SpinBox = %FpsSpinBox
@onready var _fov_slider: HSlider = %FovSlider
@onready var _fov_spin_box: SpinBox = %FovSpinBox


func _setup_video_settings() -> void:
	var video_settings: Dictionary = SettingsManager.load_video_settings()
	_old_video_settings = video_settings.duplicate()
	_new_video_settings = video_settings.duplicate()
	
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
	_fov_slider.value = video_settings.field_of_view
	_fov_slider.value_changed.connect(_on_field_of_view_changed)
	
	_fov_spin_box.value = video_settings.field_of_view
	_fov_spin_box.value_changed.connect(_on_field_of_view_changed)


func _on_display_mode_changed(index: int) -> void:
	_new_video_settings.display_mode = index
	SettingsManager.set_display_mode(index)
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_vsync_mode_changed(index: int) -> void:
	_new_video_settings.vsync_mode = index
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
	_new_video_settings.max_fps = value
	_fps_slider.value = value
	_fps_spin_box.value = value
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_field_of_view_changed(value: float) -> void:
	_new_video_settings.field_of_view = value
	_fov_slider.value = value
	_fov_spin_box.value = value
	SettingsManager.fov_updated.emit(value)
	
	# Disable the apply button if the new and old values aren't matching
	_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion
