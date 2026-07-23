extends Line2D

var twn: Tween

@onready var outline: Line2D = $Outline
@onready var platform: Platform = $".."
@onready var poly: CollisionPolygon2D = $"../CollisionPolygon2D"
@onready var bg: Polygon2D = $Polygon2D

func _points_updated(p: PackedVector2Array) -> void:

	poly.polygon = Geometry2D.offset_polygon(p, -8, Geometry2D.JOIN_ROUND)[0]
	if points.is_empty():
		points = p
		outline.points = p
		bg.polygon = p
	else:
		if twn: twn.kill()
		twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
		twn.tween_property(self, ^"points", p, 1.)
		twn.tween_property(outline, ^"points", p, 1.)
		twn.tween_property(bg, ^"polygon", p, 1.)
