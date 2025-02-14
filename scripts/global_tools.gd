class_name GlobalTools


## Comment
static func get_event(key: String) -> InputEvent:
	return InputMap.get_action_list(key)[0]


## Comment
static func inputs_empty(inputs: Array) -> bool:
	return int(inputs[0]) > inputs.size()


## Comment
static func send_signal(signal_target: Node, signal_name: String, obj: Object, method: String) -> void:
	if obj.connect(signal_name, signal_target, method):
		push_warning("Attempted to connect %s %s." % [obj.get_class(), signal_name])


## Comment
static func texture_from_image(file_path: String, crop_transparent := true) -> Texture:
	## Comment
	var image := Image.new()

	## Comment
	var new_texture := ImageTexture.new()

	if file_path.begins_with("res://"):
		image = (load(file_path) as Texture).get_data()

	elif image.load(file_path):
		return new_texture

	if crop_transparent and not image.is_invisible():
		image = image.get_rect(image.get_used_rect())

	new_texture.create_from_image(image)
	return new_texture
