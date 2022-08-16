class_name VolumeControl
extends CanvasItem

const PROGRESS_TWEENS := []
const VOL_TWEENS := []

var _self_tween := SceneTreeTween.new()

onready var root := $"/root" as Root
onready var timer := get_tree().create_timer(0)
onready var vols := [$Bars/Master, $Bars/Specifics/Music, $Bars/Specifics/SFX]


func _ready() -> void:
	for _i in range(vols.size()):
		PROGRESS_TWEENS.append(SceneTreeTween.new())
		VOL_TWEENS.append(SceneTreeTween.new())


func change_channel(channel: int, needs_visible := true) -> void:
	if needs_visible and not modulate.a:
		return
	root.volume_changing = (channel % vols.size()) if modulate.a else 0

	for i in range(vols.size()):
		var colour := Color.white if i == root.volume_changing else Color(1, 1, 1, 0.5)
		var vol: CanvasItem = vols[i] # UNSAFE ArrayItem

		if vol.modulate == colour or not modulate.a:
			vol.modulate = colour
			continue
		VOL_TWEENS[i] = _new_tween(VOL_TWEENS[i])
		var _tween = VOL_TWEENS[i].tween_property(vol, "modulate", colour, 0.2) # UNSAFE ArrayItem

	# appearance_timeout function
	if modulate.a < 1:
		_self_tween = _new_tween(_self_tween)
		var _tween := _self_tween.tween_property(self, "modulate", Color.white, 0.25)

	timer = get_tree().create_timer(2)
	if timer.connect("timeout", self, "timeout"):
		push_warning("Attempted to connect timer timeout.")


func change_volume(amount: float) -> void:
	change_channel(root.volume_changing, false)

	var channel_volume := clamp(db2linear(AudioServer.get_bus_volume_db(root.volume_changing)) + amount, 0, 1)

	set_volume(root.volume_changing, channel_volume, true)

	var change_sound := $ChangeSound as AudioStreamPlayer
	change_sound.pitch_scale = channel_volume / 2 + 1
	change_sound.play()


func set_volume(channel: int, amount: float, needs_tween := false) -> void:
	AudioServer.set_bus_volume_db(channel, linear2db(amount))

	amount = round(amount * 100)
	var vol: CanvasItem = vols[channel] # UNSAFE ArrayItem
	(vol.get_node("Percentage") as Label).text = str(amount)

	var progress := vol.get_node("TextureProgress") as TextureProgress
	if not needs_tween:
		progress.value = amount
		return

	PROGRESS_TWEENS[channel] = _new_tween(PROGRESS_TWEENS[channel]) # UNSAFE ArrayItem
	var _tween = PROGRESS_TWEENS[channel].tween_property(progress, "value", amount, 0.2) # UNSAFE ArrayItem


func timeout() -> void:
	if timer.time_left <= 0:
		_self_tween = _new_tween(_self_tween)
		var _tween := _self_tween.tween_property(self, "modulate", Color.transparent, 1)


func _new_tween(old_tween: SceneTreeTween) -> SceneTreeTween:
	if old_tween.is_valid():
		old_tween.kill()
	return create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
