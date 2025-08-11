extends Object
class_name Utility


const USER_PATH: String = "user://"
const DEBUG_PATH: String = "res://debug/"


static func get_data_dir_path() -> String:
	return DEBUG_PATH if OS.is_debug_build() else USER_PATH


## Send a raycast form the mouse position on the screen into the 3d world.
static func screen_to_world_3d_ray_cast(
		viewport: Viewport,
		camera: Camera3D,
		ray_length: float = 100.0,
		collide_with_areas: bool = false,
		collide_with_bodies: bool = true,
) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + (camera.project_ray_normal(mouse_pos) * ray_length)
	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = collide_with_areas
	ray_query.collide_with_bodies = collide_with_bodies
	return space.intersect_ray(ray_query)


## Converts every axis in a Vector3 from degrees to radians.
static func vec3_deg_to_rad(vector: Vector3) -> Vector3:
	var x: float = deg_to_rad(vector.x)
	var y: float = deg_to_rad(vector.y)
	var z: float = deg_to_rad(vector.z)
	return Vector3(x, y, z)


## Converts every axis in a Vector3 from radians to degrees.
static func vec3_rad_to_deg(vector: Vector3) -> Vector3:
	var x: float = rad_to_deg(vector.x)
	var y: float = rad_to_deg(vector.y)
	var z: float = rad_to_deg(vector.z)
	return Vector3(x, y, z)


## Converts a string that looks like -> (1.0, 1.0) into a vector 2
##CREDITS: Nartapok - https://www.reddit.com/r/godot/comments/4t25y1/string_to_vector2/
static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		
		return Vector2(array[0], array[1])
	
	return Vector2.ZERO


## Gets all the overlapping nodes in an Area3D
static func get_overlapping_nodes(area: Area3D, force_transform_update: bool = false) -> Array[Node3D]:
	var nodes: Array[Node3D] = []
	if force_transform_update:
		area.force_update_transform()
	nodes.append_array(area.get_overlapping_areas())
	nodes.append_array(area.get_overlapping_bodies())
	return nodes


static func save_data_to_file(path: String, data: Dictionary) -> void:
	# Create/open a file to write to
	var file_access := FileAccess.open(path, FileAccess.WRITE)
	# Turn data dict into a string and save it on the save file
	file_access.store_string(JSON.stringify(data, "\t"))


static func load_data_from_file(path: String) -> Dictionary:
	var data: Dictionary = {}
	# Check if file exists
	if FileAccess.file_exists(path):
		# Open file so that data can be read from it
		var file_access := FileAccess.open(path, FileAccess.READ)
		# Parse the file and set the data dict to the result
		data = JSON.parse_string(file_access.get_as_text())
	return data
