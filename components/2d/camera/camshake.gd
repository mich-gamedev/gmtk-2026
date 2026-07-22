extends CameraOffsetter

var noise := FastNoiseLite.new()

var intensity: float
var speed_scale: float = 1
var time: float
var twn: Tween

func _init(new_intensity: float = 18., new_speed_scale: float = 1, attack_time_sec: float = 0.1, decay_time_sec: float = .5) -> void:
	speed_scale = new_speed_scale
	twn = MainCam.cam.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	twn.tween_property(self, ^"intensity", new_intensity, attack_time_sec)
	twn.tween_property(self, ^"intensity", 0, decay_time_sec)

func _get_offset() -> Vector2:
	time = Time.get_ticks_usec() / 1e-6 / speed_scale
	return (Vector2.RIGHT * noise.get_noise_2d(time, 0) * intensity / 2).rotated(noise.get_noise_2d(0, time) * PI)

func _is_finished() -> bool:
	return !twn.is_valid()
