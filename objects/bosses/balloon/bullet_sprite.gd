extends Node2D

@onready var bullet: Bullet = $".."
@onready var ring_draw: RingDraw = $"../RingDraw"
@onready var sfx_ricochet: AudioStreamPlayer2D = %SFXRicochet



const FX_SPAWN = preload("uid://1cxdqxcr7qpo")

var twn: Tween

func _bullet_destroying() -> void:
	var fx := FX_SPAWN.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = global_position
	fx.reset_physics_interpolation()

func _on_bullet_bounced() -> void:
	sfx_ricochet.play()
	ring_draw.rotation = bullet.velocity.angle() + PI/2
	ring_draw.scale = Vector2(2, .5)
	if twn: twn.kill()
	twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	twn.tween_property(ring_draw, ^"scale", Vector2.ONE, 1)
