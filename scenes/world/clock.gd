extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label: RichTextLabel = $Label
@onready var survive_timer: Timer = %SurviveTimer

func _ready() -> void:
	GameLoop.state_changed.connect(_state_changed)
	_state_changed(GameLoop.state, GameLoop.state)

func _process(delta: float) -> void:
	rotation = MainCam.cam.get_screen_rotation()
	if GameLoop.state == GameLoop.STATE_SURVIVE:
		label.text = "%02d" % survive_timer.time_left

func shake() -> void:
	MainCam.add_cam_offsetter(CameraShake.new())

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_PICK_SEGMENT:
			label.text = "[font_size=48]PICK\n[font_size=16]new segment"
			anim.play(&"show")
		GameLoop.STATE_PLACE_SEGMENT:
			label.text = "[font_size=40]PLACE\n[font_size=16]your segment"
			anim.play(&"show")
		GameLoop.STATE_SURVIVE:
			anim.play(&"show")
		_:
			anim.play(&"RESET")
