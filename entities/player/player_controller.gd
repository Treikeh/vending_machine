extends RigidBody3D


func _ready() -> void:
	ground_check.player = self
	
	# Set initial state machine
	state_machine.switch(FALLING)


func _physics_process(delta: float) -> void:
	# Process phycics callback on the state state machine
	state_machine.physics(delta)


#region Input

@export_group("Input")
@export var orientation: Node3D
@export var head: Node3D
@export var interact_ray: RayCast3D


func _on_looked(vector: Vector2) -> void:
	orientation.rotate_object_local(Vector3.UP, vector.x)
	head.rotate_object_local(Vector3.RIGHT, vector.y)
	head.rotation.x = clampf(head.rotation.x, -deg_to_rad(89), deg_to_rad(89))


func _on_moved(dir: Vector2) -> void:
	move_direction = orientation.global_basis * Vector3(dir.x, 0.0, dir.y).normalized()


func _on_jumped(pressed: bool) -> void:
	is_jumping = pressed


func _on_interacted() -> void:
	interact_ray.interact_with_target(self)


func _on_item_used() -> void:
	_use_held_item()


func _on_item_thrown() -> void:
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
@export var throw_force: float = 5.0
@export var held_item_transfrom: RemoteTransform3D

var held_item: RigidBody3D


func pick_up_item(item: RigidBody3D) -> void:
	# Don't pick up item when already holding an item
	if held_item:
		return
	
	held_item = item
	
	# Disable rigidbody
	held_item.linear_velocity = Vector3.ZERO
	held_item.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Reset held_item_transfom so that it can pick up nodes with the same NodePath as the previous->
	# <-held_item, if it was destoryed while using it.
	held_item_transfrom.remote_path = ""
	# Attach rigidbody to remote transfrom
	held_item_transfrom.remote_path = item.get_path()


func _use_held_item() -> void:
	if held_item and held_item.has_method("use_item"):
		held_item.use_item()


func _throw_held_item() -> void:
	if held_item:
		held_item_transfrom.remote_path = ""
		held_item.process_mode = Node.PROCESS_MODE_INHERIT
		held_item.apply_central_impulse(-head.global_basis.z * throw_force * held_item.mass)
		held_item = null

#endregion
