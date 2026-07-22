class_name DecelerateBulletEffect extends Node

@export var bullet: Bullet
@export var decel_rate: float = 80

func _physics_process(delta: float) -> void:
	bullet.velocity = bullet.velocity.move_toward(Vector2(), decel_rate * delta)
