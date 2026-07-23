class_name SegmentSelector extends Line2D

@onready var bg: Polygon2D = $Polygon2D
@onready var anim: AnimationPlayer = $Anim

var twn: Tween

signal selected(index: int)
signal changed(index: int)

@export var segment: int:
	set(v):
		segment = wrapi(v, 0, Platform.node.displayed_segments.size())
		clear_points()
		var new: PackedVector2Array = [
			Vector2.ZERO,
			Vector2.from_angle(float(segment)/Platform.node.displayed_segments.size() * TAU) * Platform.node.radius / 2,
			Vector2.from_angle(float(segment)/Platform.node.displayed_segments.size() * TAU) * Platform.node.radius * 5,
			Vector2.from_angle(float(segment + 1)/Platform.node.displayed_segments.size() * TAU) * Platform.node.radius * 5,
			Vector2.from_angle(float(segment + 1)/Platform.node.displayed_segments.size() * TAU) * Platform.node.radius / 2,
			Vector2.ZERO
		]
		if twn: twn.kill()
		twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
		twn.tween_property(self, ^"points", new, .25)
		twn.tween_property(bg, ^"polygon", new, .25)
		twn.tween_property(bg, ^"uv", new, .25)
		changed.emit(segment)

static var node: SegmentSelector

func _ready() -> void:
	node = self
	segment = 0
	GameLoop.state_changed.connect(_state_changed)

func _process(delta: float) -> void:
	if GameLoop.state in [GameLoop.STATE_PICK_SEGMENT, GameLoop.STATE_PLACE_SEGMENT]:
		if anim.assigned_animation == &"hide":
			anim.play(&"show")
		if anim.assigned_animation != &"flash":
			if Input.is_action_just_pressed(&"walk_left"): segment += 1
			if Input.is_action_just_pressed(&"walk_right"): segment -= 1
			if Input.is_action_just_pressed(&"jump"):
				if GameLoop.state == GameLoop.STATE_PICK_SEGMENT:
					FishEye.impact(.375)
				MainCam.add_cam_offsetter(CameraImpulse.new(
					16,
					((segment + .5)/Platform.node.displayed_segments.size() * TAU) + PI,
					0.1, 2, Tween.TransitionType.TRANS_CUBIC, Tween.TransitionType.TRANS_ELASTIC
				))
				anim.play(&"flash")
				anim.animation_finished.connect(func(_anim_name: StringName) -> void: selected.emit(segment), CONNECT_ONE_SHOT)
	elif anim.assigned_animation != &"hide":
		print("hiding selector")
		anim.play(&"hide")

func _state_changed(old: int, new: int) -> void:
	if GameLoop.state in [GameLoop.STATE_PICK_SEGMENT, GameLoop.STATE_PLACE_SEGMENT] and anim.assigned_animation == &"flash":
		anim.play(&"show")
