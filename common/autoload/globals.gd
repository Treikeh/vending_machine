extends Node
@warning_ignore_start("unused_signal")


# Paths I have saved because i'm too lazy to find them in the file system
const MAIN_MENU_PATH: String = "uid://wwxe07fon8hy"
const SETTINGS_MENU_PATH: String = "uid://t0lpsh2ot3se"
const CREDITS_PATH: String = "uid://dkyrn54813ilp"
const WORLD_ENV_PATH: String = "uid://4jbcov8xso67"


# Player ui
signal interact_icon_updated(prompt: int)
signal throw_charge_updated(value: float)
signal throw_charge_stopped


# Utility
func screen_to_world_3d_ray_cast(
		camera: Camera3D,
		ray_length: float,
		collide_with_areas: bool = false,
		collide_with_bodies: bool = true,
) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + (camera.project_ray_normal(mouse_pos) * ray_length)
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = collide_with_areas
	ray_query.collide_with_bodies = collide_with_bodies
	return space.intersect_ray(ray_query)


## Converts every axis in a Vector3 from degrees to radians.
func vec3_deg_to_rad(vector: Vector3) -> Vector3:
	var x: float = deg_to_rad(vector.x)
	var y: float = deg_to_rad(vector.y)
	var z: float = deg_to_rad(vector.z)
	return Vector3(x, y, z)


## Converts every axis in a Vector3 from radians to degrees.
func vec3_rad_to_deg(vector: Vector3) -> Vector3:
	var x: float = rad_to_deg(vector.x)
	var y: float = rad_to_deg(vector.y)
	var z: float = rad_to_deg(vector.z)
	return Vector3(x, y, z)
