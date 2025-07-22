extends Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT, true)


func load_menu(menu_path: String) -> Control:
	# Check if scene exists
	if !ResourceLoader.exists(menu_path):
		print("ERROR!: Ui scene %s not found" % menu_path)
		return null
	
	# Load new scene and add it to the scene tree
	var new_scene: Control = load(menu_path).instantiate()
	add_child(new_scene)
	return new_scene


func unload_all_menus() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
