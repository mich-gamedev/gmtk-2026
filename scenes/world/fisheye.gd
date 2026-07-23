class_name FishEye extends ColorRect

static var node: FishEye

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node = self

static var twn: Tween

static func impact(intensity: float = -.75, attack_time: float = .15, decay_time: float = .5, attack_trans := Tween.TransitionType.TRANS_CUBIC, decay_trans := Tween.TransitionType.TRANS_CUBIC) -> void:
	if twn: twn.kill()
	twn = node.create_tween()
	twn.tween_property(node.material as ShaderMaterial, ^"shader_parameter/effect_amount", intensity, attack_time).set_ease(Tween.EASE_OUT).set_trans(attack_trans)
	twn.tween_property(node.material as ShaderMaterial, ^"shader_parameter/effect_amount", 0, decay_time).set_ease(Tween.EASE_OUT).set_trans(decay_trans)
