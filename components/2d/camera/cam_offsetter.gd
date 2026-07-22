@abstract class_name CameraOffsetter extends RefCounted

@export_enum("Offset", "Position") var mode: int
@export_enum("Shake", "Movement") var offset_type: int

@abstract func _get_offset() -> Vector2
@abstract func _is_finished() -> bool

func get_offset() -> Vector2:
	return _get_offset()

func is_finished() -> bool:
	return _is_finished()
