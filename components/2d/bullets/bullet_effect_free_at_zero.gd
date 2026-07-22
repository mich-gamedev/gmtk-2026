extends Node

@export var bullet: Bullet
@export var min_speed: float = 10

var min_speed_squared := min_speed ** 2

func _physics_process(delta: float) -> void:
	if bullet.velocity.length_squared() < min_speed_squared:
		bullet.queue_free()
