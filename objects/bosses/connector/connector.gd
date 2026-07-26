extends CharacterBody2D

const LASER = preload("uid://3so47q12h20b")

var last_bounce: Vector2
@onready var bolt: Sprite2D = $ElectricBolt
@onready var sfx_hit: AudioStreamPlayer2D = %SFXHit

func _ready() -> void:
	velocity = Vector2.from_angle(randf() * TAU) * 256
	GameLoop.state_changed.connect(_state_changed)

func _process(delta: float) -> void:
	bolt.rotation = MainCam.cam.get_screen_rotation()

func _physics_process(delta: float) -> void:
	last_bounce = last_bounce.rotated(PI/4 * delta)
	var coll := move_and_collide(velocity * delta)
	if coll:
		sfx_hit.play()
		velocity = velocity.bounce(coll.get_normal()).rotated(randf_range(-PI/8, PI/8))
		var laser := LASER.instantiate() as ConnectorLaser
		laser.point_a = last_bounce
		laser.point_b = coll.get_position()
		get_tree().current_scene.add_child(laser)
		last_bounce = coll.get_position()

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass
