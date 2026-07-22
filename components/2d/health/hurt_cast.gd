class_name HurtCast extends ShapeCast2D

@export var damage: float
@export var team: Health.Team

func _physics_process(_delta: float) -> void:
	for i in get_collision_count():
		var collider = get_collider(i)
		if collider is Hitbox and collider.team != team:
				collider.health.harm(damage)
