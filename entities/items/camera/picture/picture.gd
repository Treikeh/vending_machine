extends BaseItem
#TODO: Load image when it spawns in the hand of the player

@export var _sprite_3d: Sprite3D

var _image_time_stamp: String = ""


func with_data(img: Image, time_stamp: String) -> BaseItem:
	_sprite_3d.texture = ImageTexture.create_from_image(img)
	_image_time_stamp = time_stamp
	return self


func get_save_data() -> Dictionary:
	# Add to save manager so that it can be saved when quitting the game
	#INFO: This is done here and not in _exit_tree or another script, since i only want to save the
	# images on pictures that the player can access and not the images on pictures that have been
	# destroyed or have fallen through the level.
	var image_exists: bool = FileAccess.file_exists(SaveManager.IMAGE_SAVE_PATH + _image_time_stamp)
	var image_in_save_queue: bool = SaveManager.images_to_save.has(_image_time_stamp)
	if not image_exists and not image_in_save_queue:
		SaveManager.images_to_save[_image_time_stamp] = _sprite_3d.texture.get_image()
	
	var data: Dictionary = {
		"image_time_stamp": _image_time_stamp,
	}
	return data


func load_save_data(data: Dictionary) -> void:
	if not data.is_empty():
		_image_time_stamp = data.image_time_stamp
		# Check if the save manager has the image
		if SaveManager.images_to_save.has(_image_time_stamp):
			var img: Image = SaveManager.images_to_save[_image_time_stamp]
			_sprite_3d.texture = ImageTexture.create_from_image(img)
		# Check if an image file exists
		elif FileAccess.file_exists(SaveManager.IMAGE_SAVE_PATH + _image_time_stamp):
			_sprite_3d.texture = load(SaveManager.IMAGE_SAVE_PATH + _image_time_stamp)
