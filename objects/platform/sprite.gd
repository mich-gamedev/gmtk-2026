extends Line2D

var twn: Tween

@onready var outline: Line2D = $Outline
@onready var platform: Platform = $".."
@onready var poly: CollisionPolygon2D = $"../CollisionPolygon2D"
@onready var bg: Polygon2D = $Polygon2D

func _points_updated(p: Array[Vector2]) -> void:
	points = p
	poly.polygon = Geometry2D.offset_polygon(p, -8, Geometry2D.JOIN_ROUND)[0]
	outline.points = p
	bg.polygon = p
