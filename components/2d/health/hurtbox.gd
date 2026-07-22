extends Area2D
class_name Hurtbox

@export var damage: float = 1.0
@export var target: Health.Team

signal hitbox_entered(hitbox: Hitbox)

var exceptions : Array[Node]

func _ready() -> void:
	area_entered.connect(harm_hitbox)

func harm_hitbox(area: Area2D) -> void:
	if area is Hitbox and area.team == target and !(area in exceptions):
		hitbox_entered.emit(area)
		area.hurtbox_entered.emit(self)
		if area.health:
			(area.health as Health).harm(damage)
