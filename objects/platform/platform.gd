class_name Platform extends StaticBody2D

@export var radius := 128.
@export var default_point_count := 144
@export var segments: Array[PlatformSegment]

static var node: Platform

var points: Array[Vector2]

signal points_updated(p: Array[Vector2])

func _ready() -> void:
	node = self
	update()

func update() -> void:
	points.clear()
	for i in default_point_count:
		var progress := i * (1./default_point_count)
		var segment_idx := int(progress * segments.size())
		var segment_start_prog := float(segment_idx) / segments.size()
		var segment_end_prog := float(segment_idx + 1) / segments.size()
		var progress_in_segment := inverse_lerp(segment_start_prog, segment_end_prog, progress)
		if !is_finite(progress_in_segment):
			breakpoint
		var height := segments[segment_idx].get_floor_y(progress_in_segment)
		points.append(Vector2.from_angle(progress * TAU) * (1 - height) * radius)
	points_updated.emit(points)

#func _draw() -> void:
	#for i in segments.size():
		#draw_arc(Vector2.ZERO, radius * .5, i * TAU / segments.size(), (i + 1) * TAU / segments.size(), 72, Color(randf(), randf(), randf()), 4)
