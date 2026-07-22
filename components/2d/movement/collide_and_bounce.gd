extends Node
class_name CollideAndBounce

@export var body: CharacterBody2D
@export_range(0, 1, 0.01, "or_greater") var bounce_strength: float = 1
@export var bounce_other_bodies: bool = true

signal bounced()

func _physics_process(delta: float) -> void:
	var coll_info: KinematicCollision2D = body.move_and_collide(body.velocity * delta) as KinematicCollision2D

	if coll_info:
		bounced.emit()
		body.velocity = body.velocity.bounce(coll_info.get_normal()) * bounce_strength
		var collider = coll_info.get_collider()
		if collider is CharacterBody2D:
			if collider.is_in_group(&"bounceable_body"):
				collider.velocity = -body.velocity * bounce_strength
