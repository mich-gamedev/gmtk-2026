extends Node
class_name MoveBodyTowards

@export_group("Properties")
@export var active: bool = true
@export var speed: float = 128
@export var accel: float = 64
@export_range(-180, 180, 0.1, "radians_as_degrees") var offset: float:
	set(value):
		offset = value + randf_range(deg_to_rad(-5), deg_to_rad(5))
@export_group("Actors")
@export var body: Node2D
@export var target_node: Node2D
@export var target_group: StringName = &"player"

var target: Node2D
var body_vel: Vector2

func _ready() -> void:
	offset += randf_range(deg_to_rad(-22.5), deg_to_rad(22.5))

func _physics_process(delta: float) -> void:
	if active:
		target = target_node if target_node else get_tree().get_first_node_in_group(target_group)
		var direction: Vector2 = body.global_position.direction_to(target.global_position)

		if body is CharacterBody2D:
			body.velocity = body.velocity.move_toward(direction.rotated(offset) * speed, accel * delta)
		else:
			body_vel = body_vel.move_toward(direction.rotated(offset) * speed, accel * delta)
			body.position += body_vel * delta
