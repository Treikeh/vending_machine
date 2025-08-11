extends Node3D


@export_file("*.tscn") var first_level_path: String

@onready var _ui: Control = %Ui


func _ready() -> void:
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
		var viewport: Viewport = get_viewport()
		var hit: Dictionary = Utility.screen_to_world_3d_ray_cast(viewport, %Camera3D, 100.0, true)
		if hit and hit.collider is InteractArea3D:
			hit.collider.interact(self)


func _on_destroy_item_area_body_entered(body: Node3D) -> void:
	body.queue_free()



#region Buttons

func _on_play_button_pressed() -> void:
	var active_levels: Dictionary = SaveManager.get_save_data("active_levels")
	if not active_levels.is_empty():
		LevelManager.load_level(Globals.WORLD_ENV_PATH)
		for level: String in active_levels:
			var level_transform: Transform3D = str_to_var(active_levels[level])
			LevelManager.load_level(level, level_transform)
	else:
		LevelManager.load_level(Globals.WORLD_ENV_PATH)
		LevelManager.load_level(first_level_path, LevelManager.global_transform)


func _on_settings_button_pressed() -> void:
	_ui.hide()
	# Spawn settings menu
	var settings_menu: Control = GuiManager.load_menu(Globals.SETTINGS_MENU_PATH)
	settings_menu.tree_exiting.connect(_on_setting_menu_closed)


func _on_setting_menu_closed() -> void:
	_ui.show()


func _on_credits_button_pressed() -> void:
	# I load the credits in as a level since i want there to be a fade in/out when going to the credits
	# and the easiest way to do this is to load it in as a level.
	LevelManager.load_level(Globals.CREDITS_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion
