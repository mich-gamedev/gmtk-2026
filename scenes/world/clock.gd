extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label: RichTextLabel = $Label
@onready var survive_timer: Timer = %SurviveTimer
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	GameLoop.state_changed.connect(_state_changed)
	_state_changed(GameLoop.state, GameLoop.state)
	await get_tree().process_frame
	SegmentSelector.node.changed.connect(_select_changed)

func _select_changed(index: int) -> void:
	if GameLoop.state == GameLoop.STATE_MAIN_MENU:
		match index:
			0: #play
				anim.play(&"show_play" if Save.fetch().high_score else &"show_play_no_highscore")
			1: #config
				anim.play(&"show_config")
			2: #info
				anim.play(&"show_info")
			3: #exit
				anim.play(&"show_exit")

func _process(delta: float) -> void:
	rotation = MainCam.cam.get_screen_rotation()
	if GameLoop.state == GameLoop.STATE_SURVIVE and !survive_timer.is_stopped():
		label.text = "%02d" % ceil(survive_timer.time_left)

func shake() -> void:
	MainCam.add_cam_offsetter(CameraShake.new())

func _state_changed(old: int, new: int) -> void:
	sprite.texture = null
	match new:
		GameLoop.STATE_PICK_SEGMENT:
			label.text = "[font_size=48]PICK\n[font_size=16]new segment"
			anim.play(&"show")
			GreyScale.transition(.5, .25)
			FishEye.transition(-.2, .5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GameLoop.STATE_PLACE_SEGMENT:
			label.text = "[font_size=40]PLACE\n[font_size=16]your segment"
			anim.play(&"show")
		GameLoop.STATE_SURVIVE:
			GreyScale.transition(1, .25)
			label.text = "[font_size=40]LVL %02d" % GameLoop.level
			anim.play(&"show")
			await get_tree().create_timer(2).timeout
			anim.play(&"show")
		GameLoop.STATE_DIE:
			label.text = "[font_size=80]404\n[font_size=24](you died)"
			anim.play(&"show")
			GreyScale.transition(0)
			FishEye.transition(-.5, .5, Tween.EASE_OUT, Tween.TRANS_EXPO)
			if GameLoop.hp == 1: # will become 0
				await get_tree().create_timer(2).timeout
				label.text = "[font_size=96]%02d\n[font_size=32]levels" % GameLoop.level
				anim.play(&"show")
				await get_tree().create_timer(2).timeout
				GreyScale.transition(1)
		GameLoop.STATE_RESET:
			label.text = "[font_size=24]STATUS:\n[font_size=96]OK"
			anim.play(&"show")
			FishEye.transition(.2, .5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		_:
			anim.play(&"RESET")
