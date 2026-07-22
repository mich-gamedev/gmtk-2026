@icon("res://assets/class_icons/gi_anim_free_on_finish.svg")
class_name AnimFreeOnFinish extends Node

@export var animation_player: AnimationPlayer
@export var freed_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animation_player:
		animation_player.animation_finished.connect(_finished)

func _finished(_name: StringName) -> void:
	(freed_node if is_instance_valid(freed_node) else owner).queue_free()
