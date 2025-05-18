class_name SM
extends RefCounted
#CREDITS: SuperMatCat24: https://godotforums.org/d/37689-modular-state-machine

## The different callbacks states can have
enum {ENTER, PROCESS, PHYSICS, EXIT}

# The int is an enum on the owner of the state machine
var _states: Dictionary[int, Dictionary]#[int, Callable] # Same type of dict as the current variable
# _states dict[int, dict(this)] should be the same type as _current dict, but nested dicts aren't
# supported yet.
var _current: Dictionary#[int, Callable] The int is a callback on the state machine


## Create a new state machine. The int in the dict should be an enum.
## The nested dict should be [int (SM.enum), Callable (on the owner)].
## The callable can also be on a child, but then the state machine has to be created in _ready/@onready
func _init(new_states: Dictionary[int, Dictionary]) -> void:
	_states = new_states


func switch(new: int) -> void:
	var old: Dictionary = _current
	# Check if state exists before entering the new state
	if not _states.has(new):
		return
	
	_current = _states[new]# if _states.has(new) else {}
	
	if _current != old:
		if old.has(EXIT):
			old[EXIT].call()
		if _current.has(ENTER):
			_current[ENTER].call()


func process(delta: float) -> void:
	if _current.has(PROCESS):
		_current[PROCESS].call(delta)


func physics(delta: float) -> void:
	if _current.has(PHYSICS):
		_current[PHYSICS].call(delta)
