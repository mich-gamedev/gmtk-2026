class_name FreeOnDeath extends Node

@export var health: Health
@export var actor: Node
@export var delay: float

func _ready() -> void:
	health.died.connect(kill)

func kill():
	await get_tree().create_timer(delay).timeout
	await get_tree().process_frame
	actor.queue_free()
