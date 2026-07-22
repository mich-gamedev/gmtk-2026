extends Node2D
class_name FireBullet

@export_group("Scene")
@export var bullet: PackedScene
@export_group("Stats")
@export var speed: float = 160
@export var cooldown: float = 0.25
@export var damage: float = 1.0
@export_group("Random")
@export_range(0, 180, 0.01, "radians_as_degrees") var random_angle: float
@export var random_length: float
@export_group("Multifire")
@export var amount: int = 1:
	set(value):
		amount = value
		proj_space = range / float(amount)
@warning_ignore("shadowed_global_identifier")
@export_range(0,360,0.01,"radians_as_degrees") var range: float = PI/8.0:
	set(value):
		range = value
		proj_space = range / float(amount)
@export_group("Actors")
@export var is_player_gun: bool = false
@export var timer: Timer

@onready var proj_space := range / float(amount)

signal bullet_fired(bullet: Bullet)

func _ready() -> void:
	if timer and cooldown:
		timer.one_shot = true
		timer.wait_time = cooldown

func fire_bullet(direction:float) -> Array[Bullet]:
	if amount == 0:
		return []

	if !is_instance_valid(timer) or timer.time_left == 0:
		if is_instance_valid(timer):
			timer.start()
		var bullets: Array[Bullet]
		for i in amount:
			var spawned_bullet: Bullet
			spawned_bullet = bullet.instantiate()
			get_tree().current_scene.add_child.call_deferred(spawned_bullet)
			spawned_bullet.global_position = global_position
			if spawned_bullet is Bullet:
				(spawned_bullet.hurtbox as Hurtbox).damage = damage
				if amount > 1:
					var new_angle := (direction + (i * proj_space) - (range/2.0)) + randf_range(-random_angle, random_angle)
					spawned_bullet.velocity = Vector2.from_angle(new_angle) * (speed - randf_range(0, random_length))
				else:
					spawned_bullet.velocity = Vector2.from_angle(direction + randf_range(-random_angle, random_angle)) * (speed - randf_range(0, random_length))
				bullet_fired.emit(spawned_bullet)
				bullets.append(spawned_bullet)
		return bullets
	return []
