extends Node

enum {
	STATE_MAIN_MENU,
	STATE_SURVIVE,
	STATE_PICK_SEGMENT,
	STATE_PLACE_SEGMENT,
	STATE_SHOP,
	STATE_RESET,
	STATE_DIE,
}

var state := STATE_SURVIVE:
	set(v):
		state_changed.emit(state, v)
		state = v

signal state_changed(old: int, new: int)
