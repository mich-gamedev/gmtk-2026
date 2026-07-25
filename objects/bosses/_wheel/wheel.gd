extends CharacterBody2D

enum {
	STATE_TURN,
	STATE_FLIP,
	STATE_IDLE
}

var state: int:
	set(v):
		if !is_node_ready(): await ready
		state = v
		match state:
			STATE_FLIP:
				up_direction *= -1
				sprite.scale = Vector2(.75, 1/.75)
				if twn: twn.kill()
				twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
				twn.tween_property(sprite, ^"scale", Vector2.ONE, 1)
			STATE_IDLE:
				sprite.scale = Vector2(1/.75, .75)
				if twn: twn.kill()
				twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
				twn.tween_property(sprite, ^"scale", Vector2.ONE, 1)
				idle_timer.start(randf_range(.25, 1))
				direction = lerpf(-1, 1, randi_range(0, 1))

var virt_velocity: Vector2

var direction := lerpf(-1, 1, randi_range(0, 1))

const MAX_SPEED := 400

@onready var dust: Polygon2D = %Dust
@onready var scale_pivot: Node2D = %ScalePivot
@onready var sprite: Node2D = %Sprite
@onready var idle_timer: Timer = %IdleTimer
@onready var raycast: RayCast2D = $RayCast2D
@onready var swap_timer: Timer = %SwapTimer

var twn: Tween

func _ready() -> void:
	GameLoop.state_changed.connect(_state_changed)

func _physics_process(delta: float) -> void:
	virt_velocity.y += 480 * delta
	sprite.rotation += remap(virt_velocity.x, 0, 400, 0, PI*2) * delta
	dust.rotation = up_direction.angle() + PI/2
	dust.scale = Vector2.ONE * remap(abs(virt_velocity.x), 0, 400, 0, 1)

	sprite.scale.x = direction
	match state:
		STATE_TURN:
			raycast.target_position = -global_position.direction_to(Vector2.ZERO) * 40
			raycast.force_raycast_update()
			virt_velocity.x = move_toward(virt_velocity.x, MAX_SPEED, 200 * delta)
			dust.scale = Vector2.ONE * remap(virt_velocity.x, 0, 400, 0, 1)
			if raycast.is_colliding():
				up_direction = global_position.direction_to(Vector2.ZERO)
			if is_on_wall():
				virt_velocity.x = -256 * direction
				state = STATE_FLIP
			if is_on_ceiling() and swap_timer.is_stopped():
				virt_velocity.x = -256 * direction
				state = STATE_FLIP
		STATE_FLIP:
			virt_velocity.x = move_toward(virt_velocity.x, 0, 200 * delta)
			raycast.target_position = -up_direction * 40
			raycast.force_raycast_update()
			if raycast.is_colliding():
				state = STATE_IDLE
		STATE_IDLE:
			virt_velocity.x = move_toward(virt_velocity.x, 0, 200 * delta)
			up_direction = global_position.direction_to(Vector2.ZERO)

	velocity = virt_velocity.rotated(up_direction.angle() + PI/2)
	if move_and_slide():
		if get_last_slide_collision().get_collider() is Player:
			GameLoop.state = GameLoop.STATE_DIE
	virt_velocity = velocity.rotated(-(up_direction.angle() + PI/2))


func _on_idle_timer_timeout() -> void:
	state = STATE_TURN

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass
