extends BaseItem


const IMAGE_SAVE_PATH: String = "res://debug/pictures/"
const _PictureScene: PackedScene = preload("uid://3wk1okk2n03o")


@export var _sub_viewport: SubViewport
@export var _flash: Node3D
@export var _picture_spawn_point: Marker3D


func _ready() -> void:
	_flash.scale = Vector3.ZERO


func _item_used(_instigator: Node3D) -> void:
	var img: Image = _sub_viewport.get_texture().get_image()
	var time_stamp: String = Time.get_datetime_string_from_system()
	time_stamp = time_stamp.replace("T", "_")
	time_stamp = time_stamp.replace(":", "-") + ".png"
	
	# Spawn picture item
	var picture: BaseItem = _PictureScene.instantiate().with_data(img, time_stamp)
	picture.global_transform = _picture_spawn_point.global_transform
	LevelManager.add_child(picture)
	
	_flash.scale = Vector3(1.0, 1.0, 1.0)
	var flash_tween: Tween = _flash.create_tween()
	flash_tween.tween_property(_flash, "scale", Vector3.ZERO, 0.1)
