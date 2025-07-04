extends Node
@warning_ignore_start("unused_signal")


## System
var main: MainScene


## Player ui
signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


## Vending machine
signal vending_machine_code_submitted(code: String, is_valid: bool)
