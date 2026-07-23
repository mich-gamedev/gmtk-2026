@tool
class_name PlatformSegment extends Resource

## An array of pieces of wall, with the first index being the main wall connecting to the rest of the world. the X-axis represents where on the segment it's placed with 0 and 1 being each end of the segment, and the Y-axis represents how high it is, with 0 being the end of the circle and 1 being the center
@export var walls: Array[Curve] = [Curve.new()]

func get_floor_y(x: float) -> float:
	return walls[0].sample_baked(x)
