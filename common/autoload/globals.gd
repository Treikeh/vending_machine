extends Node
@warning_ignore_start("unused_signal")


# Paths I have saved because i'm too lazy to find them in the file system
const WORLD_ENV_PATH: String = "uid://4jbcov8xso67"
const MAIN_MENU_PATH: String = "uid://wwxe07fon8hy"
const QUIT_SCENE_PATH: String = "uid://cd8dmofo47nsb"
const SETTINGS_MENU_PATH: String = "uid://t0lpsh2ot3se"
const CREDITS_PATH: String = "uid://dkyrn54813ilp"


# Player ui
signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


#region Achivements


var achievements: Dictionary[String, Dictionary] = {
	"lebron_james": {
		"requirement": "Throw the basketball into the hoop",
		"complted": false,
	},
	"magical_trash_can": {
		"requirement": "Buy enough items for the trash can to appear",
		"completed": false,
		"items_bought": 0,
	},
	"no_hell_like_this_hell": {
		"requirement": "Wait in hell until the doors opens",
		"completed": false,
	},
	"product_placement": {
		"requirement": "Picked up the Godot plush",
		"completed": false,
	},
	"out_for_a_walk": {
		"requirement": "Bring the location board with you to the office",
		"completed": false,
	},
}

func _complete_achievement(achievement: String) -> void:
	achievements[achievement].completed = true

#endregion
