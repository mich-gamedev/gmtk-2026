@tool
class_name BezierToPolygon extends Path2D

@export var polygon: Polygon2D
@export var line: Line2D
@export var point_count: int
@export_tool_button("Redraw", "Edit") var redraw : Callable = queue_redraw

func _draw() -> void:
	if is_zero_approx(curve.get_baked_length()): return
	if polygon:
		polygon.polygon = []
	if line: line.clear_points()
	var follow := PathFollow2D.new()
	follow.loop = false
	add_child(follow)
	for i in point_count + 1:
		if polygon: polygon.polygon += PackedVector2Array([polygon.to_local(follow.global_position)])
		if line: line.add_point(line.to_local(follow.global_position))
		follow.progress_ratio += 1./point_count
	follow.queue_free()
