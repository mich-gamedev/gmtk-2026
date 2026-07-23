class_name Platform extends StaticBody2D

@export var radius := 128.
@export var default_point_count := 144
@export var displayed_segments: Array[PlatformSegment]

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
	FishEye.impact(-.25)
	if GameLoop.state == GameLoop.STATE_PLACE_SEGMENT:
		displayed_segments = placed_segments.duplicate()
		displayed_segments[index] = picked_segment
		update()

func _select_selected(index: int) -> void:
	print("Selected")
	match GameLoop.state:
		GameLoop.STATE_PLACE_SEGMENT:
			placed_segments[index] = picked_segment
			GameLoop.state = GameLoop.STATE_SURVIVE
		GameLoop.STATE_PICK_SEGMENT:
			picked_segment = displayed_segments[index]
			GameLoop.state = GameLoop.STATE_PLACE_SEGMENT


func update() -> void:
	points.clear()
	for i in default_point_count:
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
	print("State changed ", new)
	match new:
		GameLoop.STATE_MAIN_MENU:
			displayed_segments = get_empty_segments(6)
			update()
		GameLoop.STATE_PICK_SEGMENT:
			displayed_segments.clear()
			for i in min(PlatformSegment.unlocked_segments.size(), 6):
				displayed_segments.append(PlatformSegment.unlocked_segments.pick_random())
			update()
		GameLoop.STATE_PLACE_SEGMENT:
			displayed_segments = placed_segments.duplicate()
			displayed_segments[SegmentSelector.node.segment] = picked_segment
			update()
		GameLoop.STATE_SURVIVE:
			displayed_segments = placed_segments.duplicate()
			update()
		GameLoop.STATE_RESET:
			placed_segments = get_empty_segments(6)
			update()

func get_empty_segments(size: int) -> Array[PlatformSegment]:
	var arr : Array[PlatformSegment] = []
	arr.resize(size)
	arr.fill(PlatformSegment.new())
	return arr
