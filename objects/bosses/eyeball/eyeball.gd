extends CharacterBody2D

var turn_dir := lerpf(-1, 1, randi_range(0, 1))

enum {
	STATE_BOUNCE,
	STATE_AIM,
	STATE_DASH
}

func _ready() -> void:
	if !Player.node: await get_tree().process_frame
	velocity = global_position.direction_to(Player.node.global_position).rotated(PI) * 128
	GameLoop.state_changed.connect(_state_changed)

func _physics_process(delta: float) -> void:
	velocity = velocity.rotated(PI/4 * delta * turn_dir).move_toward(velocity.rotated(PI/4 * delta * turn_dir).limit_length(160), 640 * delta).limit_length(512)
	var coll_info := move_and_collide(velocity * delta)
	if coll_info:
		velocity = global_position.direction_to(Vector2.ZERO).rotated(randf_range(-PI/4, PI/4)) * 512
		turn_dir = lerpf(-1, 1, randi_range(0, 1))
		if coll_info.get_collider() is Player:
			GameLoop.state = GameLoop.STATE_DIE

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_RESET, GameLoop.STATE_DIE:
			queue_free()
			#pass
