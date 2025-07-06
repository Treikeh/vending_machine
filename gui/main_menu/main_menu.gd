extends Node3D


@export_file("*.tscn") var first_level_path: String

@onready var _ui: Control = %Ui
@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	_set_version_label()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Connect signals
	%PlayButton.pressed.connect(_on_play_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%CreditsButton.pressed.connect(_on_credits_button_pressed)
	%QuitButton.pressed.connect(_on_quit_button_pressed)
	%DestoryItemArea.body_entered.connect(_on_destroy_item_area_body_entered)


func _input(event: InputEvent) -> void:
	# Cast a ray into the world to interact with objects
	if event.is_action_pressed("use_item"):
		var hit: Dictionary = Globals.screen_to_world_3d_ray_cast(%Camera3D, 100.0, true)
		if hit and hit.collider is InteractArea3D:
			hit.collider.interact(self)


#region Buttons

func _on_play_button_pressed() -> void:
	Globals.main.load_level(first_level_path)


func _on_settings_button_pressed() -> void:
	_ui.hide()
	# Spawn settings menu
	var settings_menu: Control = Globals.main.load_menu(Globals.SETTINGS_MENU_PATH)
	settings_menu.tree_exiting.connect(_on_setting_menu_closed)


func _on_setting_menu_closed() -> void:
	_ui.show()


func _on_credits_button_pressed() -> void:
	#NOTE: I load the credits in as a level since i want there to be a fade to black and the only ->
	#<- place i have added a fade to black is in the level loading script
	Globals.main.load_level(Globals.CREDITS_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion



func _set_version_label() -> void:
	_version_label.text = ProjectSettings.get_setting("application/config/version")


func _on_destroy_item_area_body_entered(body: Node3D) -> void:
	body.queue_free()
