extends Node2D

@onready var survive_timer: Timer = %SurviveTimer
const FX_SPAWN = preload("uid://1cxdqxcr7qpo")
const PLAYER = preload("uid://b3vlb5w6ki5e0")

func _ready() -> void:
	BossInfo.setup()
	GameLoop.state_changed.connect(_state_changed)
	_state_changed(GameLoop.state, GameLoop.state)
	randomize_colors()

func _state_changed(old: int, new: int) -> void:
	survive_timer.stop()
	match new:
		GameLoop.STATE_SURVIVE:
			var fx := FX_SPAWN.instantiate()
			add_child(fx)
			var player := PLAYER.instantiate()
			add_child(player)
			FishEye.impact()

			await get_tree().create_timer(1).timeout
			survive_timer.start()
			var boss := BossInfo.get_random()
			var boss_fx := FX_SPAWN.instantiate() as Node2D
			boss_fx.scale = Vector2.ONE * boss.fx_radius / 16
			add_child(boss_fx)
			for i in boss.count:
				var boss_node := boss.scene.instantiate()
				add_child(boss_node)
		GameLoop.STATE_DIE:
			await get_tree().process_frame
			GameLoop.state = GameLoop.STATE_PICK_SEGMENT
		GameLoop.STATE_RESET:
			await get_tree().process_frame
			GameLoop.state = GameLoop.STATE_SURVIVE
			randomize_colors()

func _on_survive_timer_timeout() -> void:
	GameLoop.state = GameLoop.STATE_RESET

var twn: Tween

class ColorPack:
	var bg :=  Color("33e85a")
	var bg2 := Color("d1ff3f")
	var fg := Color("114e7d")
	var fg2 := Color("0a003e")
	var dg := Color("ea112b")
	var dg2 := Color("ffe61a")

var old_colors := ColorPack.new()
var new_colors := ColorPack.new()

func randomize_colors() -> void:
	old_colors = new_colors
	new_colors = ColorPack.new()
	var bg := Color.from_hsv(
		randf_range(0, 1),
		randf_range(.65, .8),
		randf_range(.85, .95)
	)
	new_colors.bg = bg
	var bg2 := bg
	bg2.s += randf_range(-.15, 0)
	bg2.v += randf_range(.1, .15)
	bg2.h = rotate_toward(bg2.h * TAU, .16 * TAU, randf_range(0.1, 0.15) * TAU) / TAU
	new_colors.bg2 = bg2

	var fg := Color.from_hsv(
		rotate_toward(bg.h * TAU, .67 * TAU, randf_range(0.4, .7) * TAU) / TAU,
		randf_range(.6, 1),
		randf_range(0.3, .55)
	)
	new_colors.fg = fg
	var fg2 := fg
	fg2.s += randf_range(-.1, .2)
	fg2.v += randf_range(-.1, -.3)
	new_colors.fg2 = fg2

	var dg := Color.from_hsv(
		#.16,
		#0. if is_equal_approx(bg.h, clamp(bg.h, 0.15, .6)) else .15,
		.67 if is_equal_approx(bg.h, clamp(bg.h, 0, 0.2)) or is_equal_approx(bg.h, clamp(bg.h, .85, 1)) else 0. if is_equal_approx(bg.h, clamp(bg.h, 0.15, .6)) else .15,
		randf_range(0.9, 1),
		randf_range(.85, .95)
	)
	print(dg.h)
	new_colors.dg = dg
	var dg2 := dg
	dg2.s += randf_range(-0.1, 0)
	dg2.v += randf_range(0.05, 0.2)
	dg2.h += randf_range(.1, .2) * lerp(-1, 1, randi_range(0, 1))
	if is_equal_approx(dg.h, .67): dg2.h = randf_range(.78, 1)
	new_colors.dg2 = dg2
	if twn: twn.kill()
	twn = create_tween()
	twn.tween_method(interp_colors, 0., 1., .5)

func interp_colors(w: float) -> void:
	RenderingServer.global_shader_parameter_set(&"green_filter", old_colors.bg.lerp(new_colors.bg, w))
	RenderingServer.global_shader_parameter_set(&"green_filter_2", old_colors.bg2.lerp(new_colors.bg2, w))
	RenderingServer.global_shader_parameter_set(&"blue_filter", old_colors.fg.lerp(new_colors.fg, w))
	RenderingServer.global_shader_parameter_set(&"blue_filter_2", old_colors.fg2.lerp(new_colors.fg2, w))
	RenderingServer.global_shader_parameter_set(&"red_filter", old_colors.dg.lerp(new_colors.dg, w))
	RenderingServer.global_shader_parameter_set(&"red_filter_2", old_colors.dg2.lerp(new_colors.dg2, w))
