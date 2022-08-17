class_name TaiClone
extends SceneTree

var _mouse: Control
var _root: Root


func _init() -> void:
	root.set_script(preload("res://scripts/root.gd"))
	_root = root as Root
	root.get_child(0).queue_free()
	var volume_control := preload("res://game/scenes/volume_control.tscn").instance() as VolumeControl
	volume_control.modulate = Color.transparent
	volume_control.hide()
	root.add_child(volume_control)
	root.add_child(preload("res://game/scenes/gameplay.tscn").instance())


func _drop_files(files: PoolStringArray, _from_screen: int) -> void:
	(root.get_node("Gameplay") as Gameplay).load_func(files[0])


func _input_event(event) -> void:
	#set_input_as_handled()
	if event is InputEventWithModifiers:
		var w_event: InputEventWithModifiers = event # UNSAFE Variant
		var vol_difference := 0.01 if w_event.control else 0.05
		var volume_control := root.get_node("VolumeControl") as VolumeControl
		if event is InputEventKey and w_event.is_pressed():
			var k_event: InputEventKey = event # UNSAFE Variant
			match k_event.scancode:
				KEY_DOWN:
					if w_event.alt:
						volume_control.change_volume(-vol_difference)
				KEY_LEFT:
					if w_event.alt and not k_event.echo:
						volume_control.change_channel(_root.volume_changing + 2, false)
				KEY_RIGHT:
					if w_event.alt and not k_event.echo:
						volume_control.change_channel(_root.volume_changing + 1, false)
				KEY_UP:
					if w_event.alt:
						volume_control.change_volume(vol_difference)
		if event is InputEventMouseButton and w_event.is_pressed():
			var b_event: InputEventMouseButton = event # UNSAFE Variant
			match b_event.button_index:
				BUTTON_WHEEL_DOWN:
					if w_event.alt:
						volume_control.change_volume(-vol_difference)
				BUTTON_WHEEL_UP:
					if w_event.alt:
						volume_control.change_volume(vol_difference)
		if event is InputEventMouseMotion:
			var m_event: InputEventMouseMotion = event # UNSAFE Variant
			if _mouse != null and not _is_hovered(_mouse, m_event.position):
				_mouse.emit_signal("mouse_exited")
				_mouse = null
			var mouse := get_nodes_in_group("Mouse")
			for i in range(mouse.size()):
				var node: Control = mouse[i] # UNSAFE Variant
				if _mouse == null and _is_hovered(node, m_event.position):
					node.emit_signal("mouse_entered")
					_mouse = node


func _is_hovered(node: Control, mouse_position: Vector2) -> bool:
	return node.get_global_rect().has_point(root.get_final_transform().affine_inverse().basis_xform(mouse_position)) and node.is_visible_in_tree()
