extends Node2D

const SEGMENT_PIECE = preload("uid://c6b05h6aoi3xq")

func _ready() -> void:
	_update()
	GameLoop.state_changed.connect(_state_changed)

func _update() -> void:
	for i in get_children():
		i.queue_free()
	var segment_count := Platform.node.displayed_segments.size()
	for i in segment_count:
		var inst := SEGMENT_PIECE.instantiate()
		add_child(inst)
		inst.rotation = float(i)/segment_count * TAU

func _state_changed(old: int, new: int) -> void:
	if new in [GameLoop.STATE_PICK_SEGMENT, GameLoop.STATE_PLACE_SEGMENT]:
		show()
		_update.call_deferred()
	else:
		hide()
