extends Node

enum {
	STATE_MAIN_MENU,
	STATE_SURVIVE,
	STATE_PICK_SEGMENT,
	STATE_PLACE_SEGMENT,
	STATE_SHOP,
	STATE_RESET,
	STATE_DIE,
	STATE_CONFIG,
	STATE_INFO
}

var state := STATE_MAIN_MENU:
	set(v):
		state_changed.emit(state, v)
		state = v

signal state_changed(old: int, new: int)

var level: int = 1
var hp: int = 3

func reset(reset_state: bool = false) -> void:
	level = 1
	hp = 3
	if reset_state: state = STATE_MAIN_MENU
