extends Node2D

@onready var fire_bullet: FireBullet = $FireBullet

func _ready() -> void:
	_on_timer_timeout()
	GameLoop.state_changed.connect(_state_changed)

func _on_timer_timeout() -> void:
	if World.node.survive_timer.time_left > 3:
		fire_bullet.fire_bullet(randf() * TAU)

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass
