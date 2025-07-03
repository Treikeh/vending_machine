extends Node
@warning_ignore_start("unused_signal")


signal load_level(level_path: String, transform: Transform3D)
signal unload_level(level_path: String)

signal add_ui_scene(scene: Node)
signal remove_all_ui_scenes


signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


signal vending_machine_code_submitted(code: String, is_valid: bool)
