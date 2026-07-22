@tool
class_name RingDraw extends Node2D

@export var width : float = 4.0:
	set(v):
		width = v
		queue_redraw()
@export var radius : float = 24.0:
	set(v):
		radius = v
		queue_redraw()
@export var draw_color: Color = Color.WHITE:
	set(v):
		draw_color = v
		queue_redraw()
@export var fill_color: Color = Color.TRANSPARENT:
	set(v):
		fill_color = v
		queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(), radius, fill_color)
	if width != 0:
		draw_circle(Vector2(), radius, draw_color, false, width)
