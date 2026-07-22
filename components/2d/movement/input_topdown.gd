extends Node

@export_group("Action Names", "act_")
@export var act_left: StringName  = &"move_left"
@export var act_right: StringName = &"move_right"
@export var act_up: StringName    = &"move_up"
@export var act_down: StringName  = &"move_down"

@export_group("Options")
@export var speed: float        = 160
@export var acceleration: float = -1
@export var deceleration: float = -1

@export_group("Actors")
@export var body: CharacterBody2D

func _physics_process(delta: float) -> void:
	var input = Input.get_vector(act_left, act_right, act_up, act_down)
	if acceleration != -1:
		if input:
			body.velocity = body.velocity.move_toward(speed * input, acceleration * delta)
		else:
				body.velocity = body.velocity.move_toward(Vector2(), (deceleration if deceleration != -1 else acceleration) * delta)
	else:
		body.velocity = speed * input
