extends HBoxContainer


@export var label: Label
@export var button: Button


func with_data(action_to_remap: String, button_pressed_callback: Callable) -> HBoxContainer:
	label.text = SettingsManager.REMAPPABLE_INPUT_ACTIONS[action_to_remap]
	button.text = InputMap.action_get_events(action_to_remap)[0].as_text().trim_suffix(" (Physical)")
	button.pressed.connect(button_pressed_callback.bind(action_to_remap, button))
	return self
