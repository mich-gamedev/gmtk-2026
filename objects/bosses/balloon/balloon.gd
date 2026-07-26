extends CharacterBody2D

var virt_velocity: Vector2

@onready var sprite: Node2D = $Sprite
@onready var fire_bullet: FireBullet = $FireBullet
@onready var sfx_hit: AudioStreamPlayer2D = %SFXHit
const SFX_POP = preload("uid://drymkjqkjal7k")

const FX_SPAWN = preload("uid://1cxdqxcr7qpo")

func _ready() -> void:
	up_direction = Vector2.from_angle(randf() * TAU)
	virt_velocity.x = 128 * lerp(-1, 1, randi_range(0, 1))
	virt_velocity.y = randf_range(16, -128)
	GameLoop.state_changed.connect(_state_changed)


var twn: Tween
func _physics_process(delta: float) -> void:
	sprite.rotation = up_direction.angle() + PI/2
	up_direction = up_direction.lerp(Player.node.up_direction, 1 - 0.1 ** delta)
	virt_velocity.y = move_toward(virt_velocity.y, 64, 256 * delta)
	virt_velocity.x = move_toward(virt_velocity.x, 0, 128 * delta)
	var coll := move_and_collide(virt_velocity.rotated(up_direction.angle() + PI/2) * delta)

	if coll:
		sfx_hit.play()
		virt_velocity.y = -256
		virt_velocity.x = 128 * lerp(-1, 1, randi_range(0, 1))
		if twn: twn.kill()
		twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		twn.tween_property(sprite, ^"scale", Vector2.ONE, 1).from(Vector2(2, .5))
		if coll.get_collider() is not Player:
			fire_bullet.fire_bullet(randf() * TAU)
			var fx := FX_SPAWN.instantiate()
			get_tree().current_scene.add_child(fx)
			fx.global_position = global_position
			fx.reset_physics_interpolation()
			var sfx := SFX_POP.instantiate()
			get_tree().current_scene.add_child(sfx)
			sfx.global_position = global_position
			sfx.reset_physics_interpolation()
			queue_free()

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass
