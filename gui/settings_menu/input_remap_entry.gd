extends HBoxContainer


var action: String

@onready var label: Label = %Label
@onready var button: Button = %Button


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


#TODO: Look into scene constructor functions
func setup_scene(new_action: String) -> void:
	action = new_action
	label.text = SettingsManager.REMAPPABLE_INPUT_ACTIONS[new_action]
	button.text = InputMap.action_get_events(new_action)[0].as_text().trim_suffix(" (Physical)")


func _input(event: InputEvent) -> void:
	if event is InputEventKey or (event is InputEventMouseButton && event.pressed):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button.text = event.as_text()
		set_process_input(false)
		accept_event()


func _on_button_pressed() -> void:
	button.text = "Press any key"
	set_process_input(true)
