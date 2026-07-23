extends CanvasLayer

func shake() -> void:
	MainCam.add_cam_offsetter(CameraShake.new())
