extends Node2D

@onready var bullet: Bullet = $".."

const FX_SPAWN = preload("uid://1cxdqxcr7qpo")

func _bullet_destroying() -> void:
	var fx := FX_SPAWN.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = global_position
	fx.reset_physics_interpolation()
