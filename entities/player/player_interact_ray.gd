extends RayCast3D


var _interact_target: InteractArea3D


func _physics_process(_delta: float) -> void:
	var target: InteractArea3D
	var prompt: String = ""
	# Check for interactable
	if is_colliding():
		var collider: Object = get_collider()
		if collider is InteractArea3D:
			target = collider
			prompt = collider.prompt
			print(prompt)
	_interact_target = target
	# Update UI


func interact_with_target(instigator: Node3D) -> void:
	if _interact_target:
		_interact_target.interact(instigator)
