class_name TaiClone
extends SceneTree

var _root: Root


func _init() -> void:
	root.set_script(preload("res://scripts/root.gd"))
	_root = root as Root
	root.get_child(0).queue_free()
	var volume_control := preload("res://game/scenes/volume_control.tscn").instance() as VolumeControl
	volume_control.modulate = Color.transparent
	root.add_child(volume_control)
	root.add_child(preload("res://game/scenes/gameplay.tscn").instance())


func _drop_files(files: PoolStringArray, _from_screen: int) -> void:
	(root.get_node("Gameplay") as Gameplay).load_func(files[0])


func _input_event(event) -> void:
	if event is InputEventMouseMotion:
		return
	#set_input_as_handled()
	if event is InputEventWithModifiers:
		var w_event: InputEventWithModifiers = event # UNSAFE Variant
		if w_event.alt and w_event.is_pressed():
			var changing := _root.volume_changing
			var vol_difference := 0.01 if w_event.control else 0.05
			var volume_control := root.get_node("VolumeControl") as VolumeControl
			if event is InputEventKey:
				var k_event: InputEventKey = event # UNSAFE Variant
				match k_event.scancode:
					KEY_DOWN:
						volume_control.change_volume(-vol_difference)
						return
					KEY_LEFT:
						if not k_event.echo:
							volume_control.change_channel(changing + 2, false)
						return
					KEY_RIGHT:
						if not k_event.echo:
							volume_control.change_channel(changing + 1, false)
						return
					KEY_UP:
						volume_control.change_volume(vol_difference)
						return
			elif event is InputEventMouseButton:
				var m_event: InputEventMouseButton = event # UNSAFE Variant
				match m_event.button_index:
					BUTTON_WHEEL_DOWN:
						volume_control.change_volume(-vol_difference)
						return
					BUTTON_WHEEL_UP:
						volume_control.change_volume(vol_difference)
						return
