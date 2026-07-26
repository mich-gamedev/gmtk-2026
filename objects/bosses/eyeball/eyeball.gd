extends CharacterBody2D

@onready var sfx_huh: AudioStreamPlayer2D = %SFXHuh
@onready var huh_timer: Timer = %HuhTimer
@onready var sfx_hit: AudioStreamPlayer2D = %SFXHit

var turn_dir := lerpf(-1, 1, randi_range(0, 1))

func _ready() -> void:
	huh_timer.start(randf_range(2, 6))
	if !Player.node: await get_tree().process_frame
	velocity = global_position.direction_to(Player.node.global_position).rotated(PI) * 128
	GameLoop.state_changed.connect(_state_changed)

func _physics_process(delta: float) -> void:
	velocity = velocity.rotated(PI/4 * delta * turn_dir).move_toward(velocity.rotated(PI/4 * delta * turn_dir).limit_length(160), 640 * delta).limit_length(400)
	var coll_info := move_and_collide(velocity * delta)
	if coll_info:
		sfx_hit.play()
		velocity = (global_position.direction_to(Vector2.ZERO) if randf() > .3 else global_position.direction_to(Player.node.global_position)).rotated(randf_range(-PI/4, PI/4)) * 400
		turn_dir = lerpf(-1, 1, randi_range(0, 1))
		if coll_info.get_collider() is Player:
			GameLoop.state = GameLoop.STATE_DIE

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass

func _on_huh_timer_timeout() -> void:
	sfx_huh.play()
	huh_timer.start(randf_range(2, 6))
