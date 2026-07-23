extends Node2D

@onready var player: Player = $"../.."
@onready var anim_stick: AnimationPlayer = %AnimStick
@onready var stick_pivot: Node2D = $StickPivot

func _physics_process(delta: float) -> void:
	scale.x = lerp(scale.x, remap(player.virt_velocity.length(), 0, player.speed, 1, 1.25), 1 - 0.000000001 ** delta)
	scale.y = lerp(scale.y, remap(player.virt_velocity.length(), 0, player.speed, 1, 1 / 1.25), 1 - 0.000000001 ** delta)
	global_rotation = lerp_angle(global_rotation, (player.velocity if !player.is_on_floor() else player.get_floor_normal().rotated(PI/2)).angle(), 1 - 0.000000001 ** delta)
	stick_pivot.global_rotation = (player.get_floor_normal() if player.is_on_floor() else player.up_direction).angle() + PI/2
	if player.is_on_floor() and anim_stick.assigned_animation != &"stick": anim_stick.play(&"stick")
	if !player.is_on_floor() and anim_stick.assigned_animation != &"unstick": anim_stick.play(&"unstick")
