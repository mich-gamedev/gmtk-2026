class_name FloatingPlatform extends StaticBody2D

var from_angle: float
var to_angle: float
var curve_top: Curve
var curve_bottom: Curve

var points: PackedVector2Array

var horizontal_point_count := 24

@onready var shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var inline: Line2D = $Line2D
@onready var outline: Line2D = $Line2D/Outline
@onready var polygon_2d: Polygon2D = $Line2D/Polygon2D

func update() -> void:
	points.clear()
	print("FLOATING PLATFORM UPDATING")
	var radius := Platform.node.radius
	for i in horizontal_point_count:
		var progress := float(i)/(horizontal_point_count - 1)
		points.append(
			Vector2.from_angle( lerp(from_angle, to_angle, progress) ) * lerp( radius, 0., curve_top.sample_baked(progress) )
		)
	for i in horizontal_point_count:
		var progress := 1 - (float(i)/(horizontal_point_count - 1))
		points.append(
			Vector2.from_angle( lerp(from_angle, to_angle, progress) ) * lerp( radius, 0., curve_bottom.sample_baked(progress) )
		)

	shape.polygon = Geometry2D.offset_polygon(points, 8, Geometry2D.JOIN_ROUND)[0]
	inline.points = points
	outline.points = points
	polygon_2d.polygon = points
