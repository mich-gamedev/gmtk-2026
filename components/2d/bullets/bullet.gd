extends CharacterBody2D
class_name Bullet

@export var bounces: int
@export var bounce_ratio: float = 1

@onready var bounces_left = bounces

signal bounced
signal destroying

func _ready() -> void:
	GameLoop.state_changed.connect(_state_changed)

func _physics_process(delta: float) -> void:
	var coll_info = move_and_collide(velocity * delta)
	if coll_info:
		if coll_info.get_collider() is Player:
			GameLoop.state = GameLoop.STATE_DIE
		bounced.emit()
		if bounces_left:
			bounces_left -= 1
			velocity = velocity.bounce(coll_info.get_normal()) * bounce_ratio
		else:
			destroying.emit()
			queue_free()

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass
