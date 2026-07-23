class_name MainCam extends Camera2D

static var cam: MainCam

var _offsetters: Array[CameraOffsetter]

var time: float

func _ready() -> void:
	cam = self

func _physics_process(delta: float) -> void:
	time += delta
	offset = Vector2.ZERO
	var finished: Array[CameraOffsetter]
	for i in _offsetters:
		if i.mode: # Position
			global_position += i.get_offset()
		else: # Offset
			offset += i.get_offset()
		if i.is_finished():
			print("Camera Offsetter finished")
			finished.append(i)
	_offsetters = _offsetters.filter(func(i: CameraOffsetter) -> bool: return !(i in finished))

static func add_cam_offsetter(inst: CameraOffsetter) -> void:
	cam._offsetters.append(inst)
