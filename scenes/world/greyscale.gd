class_name GreyScale extends ColorRect

static var node: GreyScale
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node = self

static var twn: Tween

static func transition(saturation: float, time: float = .5, ease_type: Tween.EaseType = Tween.EASE_IN, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR) -> void:
	if !is_instance_valid(node): return
	if twn: twn.kill()
	twn = node.create_tween().set_ease(ease_type).set_trans(trans_type)
	twn.tween_property(node.material, ^"shader_parameter/saturation", saturation, time)
	await twn.finished
