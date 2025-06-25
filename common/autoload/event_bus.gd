extends Node
@warning_ignore_start("unused_signal")


signal start_loading_level(level_path: String)


signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


signal vending_machine_code_submitted(code: String, is_valid: bool)
