extends BaseItem


const IMAGE_SAVE_PATH: String = "res://debug/screen_shoot.png"


@export var _sub_viewport: SubViewport


func _item_used(_instigator: Node3D) -> void:
	var img: Image = _sub_viewport.get_texture().get_image()
	img.save_png(IMAGE_SAVE_PATH)
