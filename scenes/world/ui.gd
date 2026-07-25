extends CanvasLayer

func _process(delta: float) -> void:
	rotation = MainCam.cam.get_screen_rotation()
