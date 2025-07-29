extends BaseItem


const IMAGE_SAVE_PATH: String = "res://debug/screen_shoot.png"


@export var _sub_viewport: SubViewport
@export var _flash: Node3D


func _ready() -> void:
	_flash.scale = Vector3.ZERO


func _item_used(_instigator: Node3D) -> void:
	var img: Image = _sub_viewport.get_texture().get_image()
	img.save_png(IMAGE_SAVE_PATH)
	
	_flash.scale = Vector3(1.0, 1.0, 1.0)
	var flash_tween: Tween = _flash.create_tween()
	flash_tween.tween_property(_flash, "scale", Vector3.ZERO, 0.1)
