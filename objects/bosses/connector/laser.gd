class_name ConnectorLaser extends Area2D

var point_a: Vector2
var point_b: Vector2

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var outline: Line2D = $Outline
@onready var laser: Line2D = $Laser

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	(shape.shape as SegmentShape2D).a = shape.to_local(point_a)
	(shape.shape as SegmentShape2D).b = shape.to_local(point_b)
	outline.clear_points()
	outline.add_point(outline.to_local(point_a))
	outline.add_point(outline.to_local(point_b))
	laser.clear_points()
	laser.add_point(laser.to_local(point_a))
	laser.add_point(laser.to_local(point_b))
	GameLoop.state_changed.connect(_state_changed)
	FishEye.impact(-.35)

func _process(delta: float) -> void:
	rotation += PI/4 * delta

func _state_changed(old: int, new: int) -> void:
	match new:
		GameLoop.STATE_SURVIVE:
			return
		_:
			queue_free()
			#pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameLoop.state = GameLoop.STATE_DIE
