extends ShapeCast3D


@export var _max_slope_angle: float = 46.0
## How much upwards force is needed before no longer counting as grounded
@export var _leave_floor_force: float = 5.0
## How far off the ground to move the player
@export var _rest_height: float = 1.0
@export var _spring_force: float = 300.0
@export var _spring_damping: float = 25.0

var player: RigidBody3D
var ground_normal: Vector3 = Vector3.UP

@onready var _ray_cast_3d: RayCast3D = %RayCast3D


func _ready() -> void:
	_ray_cast_3d.collision_mask = collision_mask


func is_on_walkable_slope() -> bool:
	# Leave the ground if too much upwards force is applied
	if player.linear_velocity.dot(-player.gravity_direction) >= _leave_floor_force:
	#if player.linear_velocity.y >= leave_floor_force:
		return false
	
	if is_colliding():
		# Move RayCast to ShapeCast collision point on the XZ plane (don't change height)
		var col_pos: Vector3 = get_collision_point(0)
		#ray_cast_3d.global_position = col_pos - (player.gravity_direction * 0.5)
		_ray_cast_3d.global_position.x = col_pos.x
		_ray_cast_3d.global_position.z = col_pos.z
		ground_normal = _ray_cast_3d.get_collision_normal()
		# Compare ground normal to upwards direction to get the slope angle
		if ground_normal.angle_to(Vector3.UP) < deg_to_rad(_max_slope_angle):
			return true
		return false
	return false


# Apply a spring force that moves the palyer towards "rest_height"
func snap_to_ground() -> void:
	# Check if ray cast is hitting the floor
	if not _ray_cast_3d.is_colliding():
		return
	
	var hit_distance: float = (global_position - _ray_cast_3d.get_collision_point()).length()
	var normal_vel: float = -ground_normal.dot(player.linear_velocity)
	var dispalcement: float = hit_distance - _rest_height
	var force: float = (_spring_force * dispalcement) - (normal_vel * _spring_damping)
	player.apply_central_force(player.gravity_direction * force * player.mass)
