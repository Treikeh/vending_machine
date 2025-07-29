extends Node
@warning_ignore_start("unused_signal")


# Paths I have saved because i'm too lazy to find them in the file system
const WORLD_ENV_PATH: String = "uid://4jbcov8xso67"
const MAIN_MENU_PATH: String = "uid://wwxe07fon8hy"
const QUIT_LEVEL_PATH: String = "uid://cd8dmofo47nsb"
const SETTINGS_MENU_PATH: String = "uid://t0lpsh2ot3se"
const CREDITS_PATH: String = "uid://dkyrn54813ilp"


# Player ui
signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped
