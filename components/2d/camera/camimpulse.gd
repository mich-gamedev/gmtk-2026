class_name CameraImpulse extends CameraOffsetter

var offset: Vector2
var twn: Tween

func _init(intensity: float = 20., angle: float = -1, attack_time_sec: float = 0.05, decay_time_sec: float = .15, attack_trans: Tween.TransitionType = Tween.TRANS_CUBIC, decay_trans: Tween.TransitionType = Tween.TRANS_CUBIC) -> void:
	if angle == -1: angle = randf() * TAU
	twn = MainCam.cam.create_tween().set_ease(Tween.EASE_OUT)
	twn.tween_property(self, ^"offset", Vector2.from_angle(angle) * intensity, attack_time_sec).set_trans(attack_trans)
	twn.tween_property(self, ^"offset", Vector2.ZERO, decay_time_sec).set_trans(decay_trans)

func _get_offset() -> Vector2:
	return offset

func _is_finished() -> bool:
	return !twn.is_valid()
