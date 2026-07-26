class_name World extends Node2D

@onready var double_boss: Sprite2D = %DoubleBoss
@onready var double_pick: Sprite2D = %DoublePick
@onready var double_pick_anim: AnimationPlayer = %DoublePickAnim
@onready var wildcard: Sprite2D = %Wildcard
@onready var wildcard_anim: AnimationPlayer = %WildcardAnim
@onready var survive_timer: Timer = %SurviveTimer
@onready var hp_bar: RadialProgressBar = $UI/HPBar
@onready var heartbeat_anim: AnimationPlayer = %HeartbeatAnim
@onready var ui: CanvasLayer = $UI
@onready var main_menu_symbols: Sprite2D = $MainMenuSymbols
@onready var config_symbols: Sprite2D = $ConfigSymbols
@onready var boss_warning: RadialProgressBar = %BossWarning
@onready var double_boss_sfx: AudioStreamPlayer = %DoubleBossSFX
@onready var double_pick_sfx: AudioStreamPlayer = %DoublePickSFX
@onready var wildcard_sfx: AudioStreamPlayer = %WildcardSFX
@onready var died_sfx: AudioStreamPlayer = %DiedSFX
@onready var info_label: Label = %InfoLabel

const FX_SPAWN = preload("uid://1cxdqxcr7qpo")
const PLAYER = preload("uid://b3vlb5w6ki5e0")

static var node: World

enum {
	EVENT_NONE,
	EVENT_DOUBLE_PICK,
	EVENT_WILD_CARD,
}

var boss: BossInfo

var boss_2: BossInfo

var event: int:
	set(v):
		event = v
		match v:
			EVENT_NONE:
				if double_pick_anim.assigned_animation == &"show": double_pick_anim.play(&"hide")
				if wildcard_anim.assigned_animation == &"show": wildcard_anim.play(&"hide")
			EVENT_DOUBLE_PICK:
				if double_pick_anim.assigned_animation != &"show": double_pick_anim.play(&"show")
				if wildcard_anim.assigned_animation == &"show": wildcard_anim.play(&"hide")
				double_pick_sfx.play()
			EVENT_WILD_CARD:
				if double_pick_anim.assigned_animation == &"show": double_pick_anim.play(&"hide")
				if wildcard_anim.assigned_animation != &"show": wildcard_anim.play(&"show")
				wildcard_sfx.play()

func _ready() -> void:
	node = self
	BossInfo.setup()
	boss = BossInfo.get_random()
	GameLoop.state_changed.connect(_state_changed)
	_state_changed.call_deferred(GameLoop.state, GameLoop.state)
	randomize_colors()
	adjust_hp()
	await get_tree().process_frame
	SegmentSelector.node.selected.connect(_select_selected)

func _select_selected(index: int) -> void:
	match GameLoop.state:
		GameLoop.STATE_CONFIG:
			match index:
				0: # music
					Save.fetch().vol_music = wrapf(Save.fetch().vol_music + .25, 0, 1.25)
				1: # sfx
					Save.fetch().vol_sfx = wrapf(Save.fetch().vol_sfx + .25, 0, 1.25)
				2: # fullscreen
					Save.fetch().fullscreen = !Save.fetch().fullscreen
				3: # vsync
					Save.fetch().vsync = !Save.fetch().vsync
				4: # rotate
					Save.fetch().rotate_world = !Save.fetch().rotate_world
					if !Save.fetch().fullscreen:
						MainCam.cam.rotation = 0
				5: # back
					GameLoop.state = GameLoop.STATE_MAIN_MENU
		GameLoop.STATE_MAIN_MENU:
			match index:
				0: #play
					GameLoop.state = GameLoop.STATE_PICK_SEGMENT
				1: #config
					GameLoop.state = GameLoop.STATE_CONFIG
				2: #info
					GameLoop.state = GameLoop.STATE_INFO
				3: #exit
					get_tree().quit()

var twn_warn: Tween

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released(&"jump") and GameLoop.state == GameLoop.STATE_INFO:
		GameLoop.state = GameLoop.STATE_MAIN_MENU


func _state_changed(old: int, new: int) -> void:
	info_label.hide()
	config_symbols.hide()
	main_menu_symbols.hide()
	survive_timer.stop()
	match new:
		GameLoop.STATE_MAIN_MENU:
			MusicHandler.transition(MusicHandler.SONG_RAND, 0.5)
			GameLoop.reset()
			Save.save()
			ui.hide()
			main_menu_symbols.show()
			if !Save.fetch().rotate_world: main_menu_symbols.texture = load("res://assets/polar_assets/play_no_rot.svg")
		GameLoop.STATE_CONFIG:
			config_symbols.show()
			if !Save.fetch().rotate_world: config_symbols.texture = load("res://assets/polar_assets/config_no_rot.svg")
		GameLoop.STATE_SURVIVE:
			MusicHandler.transition(MusicHandler.SONG_RAND, 2)
			print(boss.resource_path)
			ui.show()
			await get_tree().create_timer(.5).timeout
			var fx := FX_SPAWN.instantiate()
			add_child(fx)
			var player := PLAYER.instantiate()
			add_child(player)
			FishEye.impact()
			boss_warning.show()
			twn_warn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			twn_warn.tween_property(boss_warning, ^"value", 8, 1.5)

			await get_tree().create_timer(1.5).timeout
			survive_timer.start()
			var boss_fx := FX_SPAWN.instantiate() as Node2D
			boss_fx.scale = Vector2.ONE * boss.fx_radius / 16
			add_child(boss_fx)
			boss_warning.hide()
			boss_warning.value = 0
			for i in boss.double_boss_count if boss_2 else boss.count:
				var boss_node := boss.scene.instantiate()
				add_child(boss_node)
			if boss_2:
				await get_tree().create_timer(.5).timeout
				boss_fx = FX_SPAWN.instantiate() as Node2D
				boss_fx.scale = Vector2.ONE * boss_2.fx_radius / 16
				add_child(boss_fx)
				for i in boss_2.double_boss_count:
					var boss_node := boss_2.scene.instantiate()
					add_child(boss_node)
		GameLoop.STATE_DIE:
			MusicHandler.transition(MusicHandler.SONG_DIED, 0.5)
			died_sfx.play(.1)
			GameLoop.hp -= 1
			adjust_hp()
			if GameLoop.hp > 0:
				await get_tree().create_timer(1).timeout
				GameLoop.state = GameLoop.STATE_PICK_SEGMENT
				if randf() < .05:
					event = EVENT_DOUBLE_PICK
				else:
					event = EVENT_NONE
			else:
				if GameLoop.level > Save.fetch().high_score:
					Save.fetch().high_score = GameLoop.level
				await get_tree().create_timer(4).timeout
				GameLoop.state = GameLoop.STATE_MAIN_MENU
		GameLoop.STATE_RESET:
			GameLoop.hp += randi_range(0, 2) / (1 if GameLoop.hp < 3 else 2) + (1 if GameLoop.hp < 2 else 0)
			adjust_hp()
			GameLoop.level += 1
			survive_timer.wait_time += randi_range(0, 3) * (2 if GameLoop.hp > 5 else 1)
			if randf() < .2:
				event = [EVENT_DOUBLE_PICK, EVENT_WILD_CARD].pick_random()
			else:
				event = EVENT_NONE
			await get_tree().create_timer(.5).timeout
			GameLoop.state = GameLoop.STATE_PICK_SEGMENT if event != EVENT_WILD_CARD else GameLoop.STATE_SURVIVE
			randomize_colors()
			boss = BossInfo.get_random()
			if randf() < .2 * (2.5 if GameLoop.hp > 5 else 1.):
				boss_2 = BossInfo.get_random()
				double_boss.show()
				double_boss_sfx.play()
			else:
				boss_2 = null
				double_boss.hide()
		GameLoop.STATE_INFO:
			info_label.show()

func adjust_hp() -> void:
	hp_bar.max_value = max(GameLoop.hp, 3)
	hp_bar.value = GameLoop.hp
	heartbeat_anim.speed_scale = remap(GameLoop.hp, 3, 1, 1.25, 5)

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
