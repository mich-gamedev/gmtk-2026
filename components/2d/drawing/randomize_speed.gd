extends AnimatedSprite2D

@export var min_scale: float = 0.8
@export var max_scale: float = 1.2

func _ready() -> void:
	speed_scale = randf_range(min_scale,max_scale)
