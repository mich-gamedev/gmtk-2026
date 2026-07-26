class_name MusicHandler extends Node

static var node: MusicHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node = self

static var twn: Tween

enum {
	SONG_RAND = -1,
	SONG_MAIN_0 = 0,
	SONG_MAIN_1 = 1,
	SONG_DIED = 2
}

static var chance: Dictionary[int, float] = {
	SONG_MAIN_0: 1.,
	SONG_MAIN_1: 1.,
}

static func transition(to: int, duration: float = .5) -> void:
	var rng := RandomNumberGenerator.new()
	if to == SONG_RAND:
		to = chance.keys()[rng.rand_weighted(chance.values())]
		for i in chance:
			if i == to:
				chance[i] -= .1
			else:
				chance[i] += .1
	print("NEW SONG: ", to)
	if twn: twn.kill()
	twn = node.create_tween().set_parallel()
	for i in node.get_child_count():
		if i == to:
			twn.tween_property(node.get_child(i), ^"volume_db", -5, duration)
		else:
			twn.tween_property(node.get_child(i), ^"volume_db", -80, duration * 8)
