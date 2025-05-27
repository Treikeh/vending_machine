extends RigidBody3D


func _ready() -> void:
	ground_check.player = self
	
	# Set initial state machine
	state_machine.switch(FALLING)


func _process(delta: float) -> void:
	if rmb_pressed:
		rmb_held_time += delta
		if held_item:
			EventBus.throw_charge_bar_updated.emit(rmb_held_time)


func _physics_process(delta: float) -> void:
	# Process phycics callback on the state state machine
	state_machine.physics(delta)


#region Input

@export_group("Input")
@export var interact_window: float = 0.5
@export var orientation: Node3D
@export var head: Node3D
@export var interact_ray: RayCast3D

var rmb_pressed: bool = false
var rmb_held_time: float = 0.0


func _on_looked(vector: Vector2) -> void:
	orientation.rotate_object_local(Vector3.UP, vector.x)
	head.rotate_object_local(Vector3.RIGHT, vector.y)
	head.rotation.x = clampf(head.rotation.x, -deg_to_rad(89), deg_to_rad(89))


func _on_moved(dir: Vector2) -> void:
	move_direction = orientation.global_basis * Vector3(dir.x, 0.0, dir.y).normalized()


func _on_jumped(pressed: bool) -> void:
	is_jumping = pressed


func _on_item_used() -> void:
	_use_held_item()


func _on_item_thrown(pressed: bool) -> void:
	rmb_pressed = pressed
	if pressed:
		# Reset rmb_held_time. Subtract interact_window to do something smart, i guess....
		rmb_held_time = 0.0 - interact_window
	# Interact with target if rmb hasn't been held down for longer that the interact window
	elif rmb_held_time < 0.0:
		interact_ray.interact_with_target(self)
	# Throw item when rmb is released and the rmb_held_time is greater than 0.0
	else:
		_throw_held_item()

#endregion


#region Movement

enum {WALKING, FALLING, JUMPING}

@export_group("Movement")
@export var max_speed: float = 6.0
@export var ground_accel: float = 500.0
@export var air_accel: float = 200.0
@export var jump_force: float = 5.0
@export var ground_check: ShapeCast3D

var is_jumping: bool = false
#var gravity_force: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction: Vector3 = Vector3.DOWN
var move_direction: Vector3 = Vector3.ZERO

@onready var state_machine := SM.new({
	WALKING: {SM.ENTER: _walking_enter, SM.PHYSICS: _walking_physics},
	FALLING: {SM.ENTER: _falling_enter, SM.PHYSICS: _falling_physics},
	JUMPING: {SM.ENTER: _jumping_enter},
})


func _walking_enter() -> void:
	gravity_scale = 0.0
	# Give ground_check a buffer to improve the snapping when walking down ledges
	ground_check.target_position.y = -1.0

func _walking_physics(delta: float) -> void:
	if not ground_check.is_grounded:
		state_machine.switch(FALLING)
		return
	
	if is_jumping:
		state_machine.switch(JUMPING)
		return
	
	var target_vel: Vector3 = move_direction * max_speed
	var needed_vel: Vector3 = target_vel - linear_velocity
	apply_central_force(needed_vel * ground_accel * delta * mass)


func _falling_enter() -> void:
	gravity_scale = 1.0
	# Reduce ground_check size while airborne to get more accurate landing collision
	ground_check.target_position.y = -0.6

func _falling_physics(delta: float) -> void:
	if ground_check.is_grounded:
		state_machine.switch(WALKING)
		return
	
	var target_vel: Vector3 = move_direction * max_speed
	var slope_normal: Vector3 = Vector3.ZERO
	
	#Bad fix for sliding up steep slopes while in the air
	if move_direction and ground_check.is_colliding():
		slope_normal = ground_check.ground_normal
		slope_normal = Vector3(slope_normal.x, 0.0, slope_normal.z)
		target_vel = (move_direction + slope_normal) * max_speed
	
	#var gravity_vector: Vector3 = gravity_direction * gravity_force
	var gravity_vector: Vector3 = linear_velocity.dot(gravity_direction) * gravity_direction
	var needed_vel: Vector3 = target_vel - (linear_velocity - gravity_vector)
	apply_central_force(needed_vel * air_accel * delta * mass)


func _jumping_enter() -> void:
	set_axis_velocity(-gravity_direction * jump_force)
	# Jump audio
	state_machine.switch(FALLING)

#endregion


#region Item

@export_group("Item")
@export var min_throw_force: float = 3.0
@export var max_throw_force: float = 8.0
@export var held_item_transfrom: RemoteTransform3D

var held_item: BaseItem


func pick_up_item(item: RigidBody3D) -> void:
	# 落とす　held_item いつ　拾う　新しい　もの
	if held_item:
		held_item.drop_item()
		#return
	
	held_item = item
	# Reset held_item_transfom so that it can pick up nodes with the same NodePath as the previous->
	# <-held_item, if that item was destoryed while using it.
	held_item_transfrom.remote_path = ""
	# Attach item to remote transfrom
	held_item_transfrom.remote_path = item.get_path()


func _use_held_item() -> void:
	if held_item:
		held_item.use_item()


func _throw_held_item() -> void:
	var force: float = _get_throw_force()
	if held_item:
		held_item.drop_item()
		held_item_transfrom.remote_path = ""
		held_item.apply_central_impulse(-head.global_basis.z * force * held_item.mass)
		held_item = null


# TODO: Make exponential or use a curve
func _get_throw_force() -> float:
	return remap(rmb_held_time, 0.0, 2.0, min_throw_force, max_throw_force)

#endregion
