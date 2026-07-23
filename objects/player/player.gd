class_name Player extends CharacterBody2D

static var node: Player

@export var accel: float
@export var speed: float
@export var jump_speed: float
@export var jump_gravity: float
@export var fall_gravity: float

var was_on_floor: bool
var is_jumping: bool
var can_jump: bool

var virt_velocity: Vector2

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var buffer_timer: Timer = $BufferTimer
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	GameLoop.state_changed.connect(_state_changed)

func _physics_process(delta: float) -> void:

	#region circular movement handling
	if is_on_floor() or is_on_wall():
		up_direction = global_position.direction_to(Vector2.ZERO)
	elif up_direction.angle_to(global_position.direction_to(Vector2.ZERO)) < PI/2: up_direction = global_position.direction_to(Vector2.ZERO)
	#endregion
	virt_velocity.x = move_toward(virt_velocity.x, Input.get_axis(&"walk_left", &"walk_right") * speed, accel * delta)

	#region jumping
	if is_on_floor():
		if !was_on_floor:
				MainCam.add_cam_offsetter(CameraImpulse.new(2, up_direction.angle(), 0.15, 0.15))
		was_on_floor = true
		can_jump = true
		coyote_timer.stop()
	elif was_on_floor:
		was_on_floor = false
		coyote_timer.start()

	if Input.is_action_just_pressed(&"jump"):
		if GameLoop.state != GameLoop.STATE_SURVIVE:
			print("doing the thing")
			GameLoop.state = GameLoop.STATE_SURVIVE
		is_jumping = true
		buffer_timer.start()

	if is_jumping and can_jump:
		jump()
	#endregion

	#region gravity
	var gravity := fall_gravity if (!Input.is_action_pressed(&"jump")) or virt_velocity.y > 0 else jump_gravity
	virt_velocity.y += gravity * delta

	velocity = virt_velocity.rotated(up_direction.angle() + PI/2)

	move_and_slide()
	virt_velocity = velocity.rotated(-(up_direction.angle() + PI/2))
	queue_redraw()
	shape.rotation = (get_floor_normal() if is_on_floor() else up_direction).angle() + PI/2
	#MainCam.cam.rotation = up_direction.angle()  + PI/2
	MainCam.cam.global_position = global_position * .1

func jump(jump_scale: float = 1.) -> void:
	virt_velocity.y = -jump_speed * jump_scale
	can_jump = false
	is_jumping = false

func _coyote_timeout() -> void:
	can_jump = false

func _buffer_timeout() -> void:
	is_jumping = false

#func _draw() -> void:
	#draw_line(Vector2.ZERO, up_direction * 64, Color.AQUAMARINE)

func _state_changed(old: int, new: int) -> void:
	if new in [GameLoop.STATE_RESET, GameLoop.STATE_DIE]:
		queue_free()
