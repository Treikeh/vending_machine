extends HBoxContainer


@onready var label: Label = %Label
@onready var button: Button = %Button


#TODO: Look into scene constructor functions
func setup_scene(action: String) -> void:
	label.text = SettingsManager.REMAPPABLE_INPUT_ACTIONS[action]
	button.text = InputMap.action_get_events(action)[0].as_text().trim_suffix(" (Physical)")
