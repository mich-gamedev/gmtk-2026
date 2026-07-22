extends Area2D
class_name Hitbox

@export var health: Health
@export var team: Health.Team

@warning_ignore("unused_signal")
signal hurtbox_entered(hurtbox: Hurtbox)
