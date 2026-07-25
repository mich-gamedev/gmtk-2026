extends Bullet

var moving_to_player: bool

@onready var warning: AnimationPlayer = %Warning

func _physics_process(delta: float) -> void:
	super(delta)
	if World.node.survive_timer.time_left < 2.5 and warning.assigned_animation != &"warn":
		warning.play(&"warn")
	if World.node.survive_timer.time_left < 2 and !moving_to_player:
		moving_to_player = true
		velocity = global_position.direction_to(Player.node.global_position) * 64
