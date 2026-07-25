class_name Platform extends StaticBody2D

@export var radius := 128.
@export var default_point_count := 144
@export var displayed_segments: Array[PlatformSegment]
@onready var floating_platform_container: Node2D = $FloatingPlatformContainer

static var node: Platform

var points: Array[Vector2]
var picked_segment: PlatformSegment
var placed_segments: Array[PlatformSegment] = get_empty_segments(6)

signal points_updated(p: Array[Vector2])

func _ready() -> void:
	node = self
	GameLoop.state_changed.connect(_state_changed)
	displayed_segments = get_empty_segments(6)
	update()
	if !SegmentSelector.node: await get_tree().process_frame
	SegmentSelector.node.changed.connect(_select_changed)
	SegmentSelector.node.selected.connect(_select_selected)
	_state_changed(GameLoop.state, GameLoop.state)

func _select_changed(index: int) -> void:
	print(index)
	FishEye.impact(-.25)
	match GameLoop.state:
		GameLoop.STATE_PLACE_SEGMENT:
			displayed_segments = placed_segments.duplicate()
			displayed_segments[index] = picked_segment
			update()
		GameLoop.STATE_MAIN_MENU:
			displayed_segments = get_empty_segments(4)
			displayed_segments[index] = load("uid://254mbqxxvunh")
			update()
		GameLoop.STATE_MAIN_MENU:
			displayed_segments = get_empty_segments(5)
			displayed_segments[index] = load("uid://254mbqxxvunh")
			update()

func _select_selected(index: int) -> void:
	print("Selected")
	match GameLoop.state:
		GameLoop.STATE_PLACE_SEGMENT:
			placed_segments[index] = picked_segment
			if World.node.event == World.EVENT_DOUBLE_PICK:
				GameLoop.state = GameLoop.STATE_PICK_SEGMENT
				World.node.event = World.EVENT_NONE
			else:
				GameLoop.state = GameLoop.STATE_SURVIVE
		GameLoop.STATE_PICK_SEGMENT:
			picked_segment = displayed_segments[index]
			GameLoop.state = GameLoop.STATE_PLACE_SEGMENT
		GameLoop.STATE_CONFIG:
			SegmentSelector.node.anim.play(&"show")

const FLOATING_PLATFORM = preload("uid://ckvu0yycp6hfc")

func update() -> void:
	points.clear()
	for i in floating_platform_container.get_children(): i.queue_free()
	for segment_idx in displayed_segments.size(): # floating platforms
		var start_angle := float(segment_idx) / displayed_segments.size() * TAU
		var end_angle := float(segment_idx + 1) / displayed_segments.size() * TAU
		var segment := displayed_segments[segment_idx]
		for i: int in min(segment.platform_bottoms.size(), segment.platform_ranges.size(), segment.platform_tops.size()):
			var inst := FLOATING_PLATFORM.instantiate() as FloatingPlatform
			floating_platform_container.add_child(inst)
			inst.curve_bottom = segment.platform_bottoms[i]
			inst.curve_top = segment.platform_tops[i]
			inst.from_angle = lerp(start_angle, end_angle, segment.platform_ranges[i].x)
			inst.to_angle = lerp(start_angle, end_angle, segment.platform_ranges[i].y)
			inst.update()

	for i in default_point_count: # floor
		var progress := i * (1./default_point_count)
		var segment_idx := int(progress * displayed_segments.size())
		var segment_start_prog := float(segment_idx) / displayed_segments.size()
		var segment_end_prog := float(segment_idx + 1) / displayed_segments.size()
		var progress_in_segment := inverse_lerp(segment_start_prog, segment_end_prog, progress)
		if !is_finite(progress_in_segment):
			breakpoint
		var height := displayed_segments[segment_idx].get_floor_y(progress_in_segment)
		points.append(Vector2.from_angle(progress * TAU) * (1 - height) * radius)
	points_updated.emit(points)

#func _draw() -> void:
	#for i in displayed_segments.size():
		#draw_arc(Vector2.ZERO, radius * .5, i * TAU / displayed_segments.size(), (i + 1) * TAU / displayed_segments.size(), 72, Color(randf(), randf(), randf()), 4)

func _state_changed(old: int, new: int) -> void:
	SegmentSelector.node.segment = SegmentSelector.node.segment
	print("State changed ", new)
	match new:
		GameLoop.STATE_MAIN_MENU:
			placed_segments = get_empty_segments(randi_range(3, 8))
			displayed_segments = get_empty_segments(4)
			update()
		GameLoop.STATE_CONFIG:
			displayed_segments = get_empty_segments(6)
			update()
			SegmentSelector.node.segment = 0
		GameLoop.STATE_PICK_SEGMENT:
			displayed_segments.clear()
			if Save.fetch().high_score > 0 or GameLoop.level > 1 or GameLoop.hp != 5:
				for i in placed_segments.size():
					displayed_segments.append(PlatformSegment.unlocked_segments.pick_random())
			else:
				displayed_segments = get_empty_segments(placed_segments.size())
				displayed_segments[0] = PlatformSegment.unlocked_segments.pick_random()
			update()
		GameLoop.STATE_PLACE_SEGMENT:
			displayed_segments = placed_segments.duplicate()
			displayed_segments[SegmentSelector.node.segment] = picked_segment
			update()
		GameLoop.STATE_SURVIVE:
			displayed_segments = placed_segments.duplicate()
			update()
		GameLoop.STATE_RESET:
			await get_tree().process_frame
			if World.node.event == World.EVENT_WILD_CARD:
				placed_segments.clear()
				for i in randi_range(3, 8):
					placed_segments.append(PlatformSegment.unlocked_segments.pick_random())
			else:
				placed_segments = get_empty_segments(randi_range(3, 8))
			update()

func get_empty_segments(size: int) -> Array[PlatformSegment]:
	var arr : Array[PlatformSegment] = []
	arr.resize(size)
	arr.fill(PlatformSegment.new())
	return arr
