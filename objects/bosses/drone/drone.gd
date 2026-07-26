extends CharacterBody2D

@onready var fire_bullet: FireBullet = $FireBullet
@onready var fire_timer: Timer = $FireTimer
@onready var los_check: RayCast2D = $LOSCheck
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sfx_hit: AudioStreamPlayer2D = %SFXHit
@onready var sfx_gunshot: AudioStreamPlayer2D = %SFXGunshot
@onready var sfx_burnout: AudioStreamPlayer2D = %SFXBurnout

enum {
	STATE_IDLE,
	STATE_FIRE,
	STATE_BOUNCE
}
const LAUNCH_FORCE := 640
const DECEL := 400

var state := STATE_IDLE:
	set(v):
		if !is_node_ready(): await ready
		state = v
		match v:
			STATE_BOUNCE:
				los_check.target_position = los_check.to_local(Player.node.global_position)
				los_check.force_raycast_update()
				velocity = launch_dir.rotated((PI/3 * lerp(-1, 1, randi_range(0, 1))) if los_check.is_colliding() else 0.) * LAUNCH_FORCE * launch_force_mult
				launch_force_mult = 1
			STATE_FIRE:
				fire_bullet.fire_bullet(global_position.angle_to_point(Player.node.global_position))
				fire_timer.start(randf_range(1, 3))

func _ready() -> void:
	velocity = Vector2.from_angle(randf() * TAU) * 64
	GameLoop.state_changed.connect(_state_changed)
	await get_tree().create_timer(0.5).timeout
	state = STATE_FIRE
	anim.speed_scale = randf_range(0.05, .1)

func _physics_process(delta: float) -> void:

	velocity = velocity.move_toward(Vector2.ZERO, DECEL * delta)
	match state:
		STATE_BOUNCE:
			if velocity.length() < 24:
				state = STATE_FIRE
		STATE_FIRE:
			los_check.target_position = los_check.to_local(Player.node.global_position)
			los_check.force_raycast_update()
			if los_check.is_colliding():
				launch_force_mult = .6
				_on_fire_timer_timeout()
				fire_timer.stop()
	var coll := move_and_collide(velocity * delta)
	if coll:
		velocity = velocity.bounce(coll.get_normal()) * 1.05
		sfx_hit.play()
		if coll.get_collider() is Player:
			GameLoop.state = GameLoop.STATE_DIE

func _on_timer_timeout() -> void:
	if state == STATE_FIRE:
		fire_bullet.fire_bullet(global_position.angle_to_point(Player.node.global_position))

@onready var warning: AnimationPlayer = %Warning

var launch_dir: Vector2
var launch_force_mult: float = 1

func _on_fire_timer_timeout() -> void:
	sfx_burnout.play()
	warning.play(&"warn")
	state = STATE_IDLE
	launch_dir = global_position.direction_to(Player.node.global_position)
	await get_tree().create_timer(.5).timeout
	state = STATE_BOUNCE

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass


func _on_fire_bullet_bullet_fired(bullet: Bullet) -> void:
	sfx_gunshot.play()
	velocity -= bullet.velocity * .1
