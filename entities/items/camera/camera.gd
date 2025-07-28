extends BaseItem


const IMAGE_SAVE_PATH: String = "res://debug/screen_shoot.png"


@export var _sub_viewport: SubViewport


func _item_used(_instigator: Node3D) -> void:
	var img: Image = _sub_viewport.get_texture().get_image()
	img.save_png(IMAGE_SAVE_PATH)


#region Save/Load

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		pass

#endregion
