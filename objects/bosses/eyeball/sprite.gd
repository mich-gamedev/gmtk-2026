extends Node2D

@onready var iris: RingDraw = $Iris

func _process(delta: float) -> void:
	iris.position = iris.position.lerp(Vector2.from_angle(randf() * TAU) * 12, 1 - 0.000000001 ** delta)
