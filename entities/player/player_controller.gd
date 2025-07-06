extends RigidBody3D


func _ready() -> void:
	_ground_check.player = self
	# Set initial state machine
	_state_machine.switch(FALLING)


func _process(delta: float) -> void:
	# Increase throw charge when pressing rmb and holding an item
	if _rmb_pressed and _held_item and _throw_charge < _throw_force_curve.max_domain:
		_throw_charge += delta
		_update_ui_throw_bar(_throw_charge)


func _physics_process(delta: float) -> void:
	# Process phycics callback on the state state machine
	_state_machine.physics(delta)
	
	# Apply head bobbing and camera tilt
	_camera.apply_head_bobbing(linear_velocity, delta)
	_camera.apply_camera_tilt(linear_velocity, _move_direction, delta)


#region Input

@export_group("Input")

var _rmb_pressed: bool = false

@onready var _orientation: Node3D = %Orientation
@onready var _head: Node3D = %Head
@onready var _camera: Camera3D = %Camera
@onready var _interact_ray: RayCast3D = %InteractRay


func _on_looked(vector: Vector2) -> void:
	_orientation.rotate_object_local(Vector3.UP, vector.x)
	_head.rotate_object_local(Vector3.RIGHT, vector.y)
	_head.rotation.x = clampf(_head.rotation.x, -deg_to_rad(89), deg_to_rad(89))


func _on_moved(dir: Vector2) -> void:
	_move_direction = _orientation.global_basis * Vector3(dir.x, 0.0, dir.y).normalized()


func _on_interacted() -> void:
	_interact_ray.interact_with_target(self)


func _on_jumped(pressed: bool) -> void:
	_is_jumping = pressed


func _on_item_used() -> void:
	_use_held_item()


func _on_item_thrown(pressed: bool) -> void:
	_rmb_pressed = pressed
	if pressed:
		# Reset throw_charge
		_throw_charge = 0.0
	else:
		# Throw item when rmb is released
		_throw_held_item()

#endregion


#region Movement

enum {WALKING, FALLING, JUMPING}

@export_group("Movement")
@export var _max_speed: float = 6.0
@export var _ground_accel: float = 500.0
@export var _air_accel: float = 200.0
@export var _jump_force: float = 5.0

var _is_jumping: bool = false
#var gravity_force: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction: Vector3 = Vector3.DOWN
var _move_direction: Vector3 = Vector3.ZERO

@onready var _ground_check: ShapeCast3D = %GroundCheck
@onready var _state_machine := SM.new({
	WALKING: {SM.ENTER: _walking_enter, SM.PHYSICS: _walking_physics},
	FALLING: {SM.ENTER: _falling_enter, SM.PHYSICS: _falling_physics},
	JUMPING: {SM.ENTER: _jumping_enter},
})


func _walking_enter() -> void:
	gravity_scale = 0.0
	# Give ground_check a buffer to improve the snapping when walking down ledges
	_ground_check.target_position.y = -1.0

func _walking_physics(delta: float) -> void:
	if not _ground_check.is_on_walkable_slope():
		_state_machine.switch(FALLING)
		return
	
	if _is_jumping:
		_state_machine.switch(JUMPING)
		return
	
	var target_vel: Vector3 = _move_direction * _max_speed
	var needed_vel: Vector3 = target_vel - linear_velocity
	apply_central_force(needed_vel * _ground_accel * delta * mass)
	_ground_check.snap_to_ground()


func _falling_enter() -> void:
	gravity_scale = 1.0
	# Reduce ground_check size while airborne to get more accurate landing collision
	_ground_check.target_position.y = -0.6

func _falling_physics(delta: float) -> void:
	if _ground_check.is_on_walkable_slope():
		_state_machine.switch(WALKING)
		return
	
	var target_vel: Vector3 = _move_direction * _max_speed
	var slope_normal: Vector3 = Vector3.ZERO
	
	#Bad fix for sliding up steep slopes while in the air
	if _move_direction and _ground_check.is_colliding():
		slope_normal = _ground_check.ground_normal
		slope_normal = Vector3(slope_normal.x, 0.0, slope_normal.z)
		target_vel = (_move_direction + slope_normal) * _max_speed
	
	#var gravity_vector: Vector3 = gravity_direction * gravity_force
	var gravity_vector: Vector3 = linear_velocity.dot(gravity_direction) * gravity_direction
	var needed_vel: Vector3 = target_vel - (linear_velocity - gravity_vector)
	apply_central_force(needed_vel * _air_accel * delta * mass)


func _jumping_enter() -> void:
	#apply_central_impulse(-gravity_direction * jump_force)
	# This is actually a better choice causes a small "hitch" when jumping, which is distracting
	# NOTE: The cause of the "hitch" might be in another script
	set_axis_velocity(-gravity_direction * _jump_force)
	# Jump audio
	_state_machine.switch(FALLING)

#endregion


#region Item

@export_group("Item")
@export var _throw_force_curve: Curve

var _throw_charge: float = 0.0
var _held_item: BaseItem

@onready var _held_item_transform: RemoteTransform3D = %HeldItemTransform


func pick_up_item(item: BaseItem) -> void:
	# Drop　held_item when　picking up　new　item
	if _held_item:
		_held_item.drop_item(self)
		#return
	
	_held_item = item
	# Reset held_item_transfom so that it can pick up nodes with the same NodePath as the previous->
	# <-held_item, if that item was destoryed while using it.
	_held_item_transform.remote_path = ""
	# Attach item to remote transfrom
	_held_item_transform.remote_path = item.get_path()


func _use_held_item() -> void:
	if _held_item:
		_held_item.use_item(self)


func _throw_held_item() -> void:
	var force: float = _throw_force_curve.sample(_throw_charge)
	if _held_item:
		_held_item.drop_item(self)
		_held_item_transform.remote_path = ""
		_held_item.global_transform = _head.global_transform
		_held_item.apply_central_impulse(-_head.global_basis.z * force * _held_item.mass)
		_held_item = null
		Globals.throw_charge_stopped.emit()


func _update_ui_throw_bar(sample_offset: float) -> void:
	var i_start: float = _throw_force_curve.min_value
	var i_stop: float = _throw_force_curve.max_value
	var sample: float = _throw_force_curve.sample(sample_offset)
	# Remap sample to a range of 0.0 -> 1.0
	var value: float = remap(sample, i_start, i_stop, 0.0, 1.0)
	Globals.throw_charge_updated.emit(value)

#endregion
