@tool
class_name PlatformSegment extends Resource

@export var floor: Curve = Curve.new()
@export var platform_bottoms: Array[Curve]
@export var platform_tops: Array[Curve]

func get_floor_y(x: float) -> float:
	return floor.sample_baked(x)

static var unlocked_segments: Array[PlatformSegment] = file_segments
static var file_segments: Array[PlatformSegment]:
	get:
		if file_segments.is_empty():
			var list := ResourceLoader.list_directory("res://resources/segments/purchasable/")
			for i in list:
				file_segments.append(load("res://resources/segments/purchasable/".path_join(i)))
		return file_segments
