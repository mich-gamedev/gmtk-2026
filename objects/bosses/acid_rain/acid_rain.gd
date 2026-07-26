extends Node2D

@onready var fire_bullet: FireBullet = $FireBullet
@onready var sfx_turn: AudioStreamPlayer = %SFXTurn

func _ready() -> void:
	_on_timer_timeout()
	GameLoop.state_changed.connect(_state_changed)

var has_warned: bool

func _physics_process(delta: float) -> void:
	if World.node.survive_timer.time_left < 2.5 and !has_warned:
		has_warned = true
		sfx_turn.play()

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
