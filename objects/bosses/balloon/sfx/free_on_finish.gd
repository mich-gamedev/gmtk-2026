class_name SFXFreeOnFinish extends Node

@export var sfx: Node
@export var freed_node: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sfx is AudioStreamPlayer:
		sfx.finished.connect(freed_node.queue_free)
	if sfx is AudioStreamPlayer2D:
		sfx.finished.connect(freed_node.queue_free)
	if sfx is AudioStreamPlayer3D:
		sfx.finished.connect(freed_node.queue_free)
