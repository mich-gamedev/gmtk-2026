extends Node

enum {
	STATE_MAIN_MENU,
	STATE_SURVIVE,
	STATE_PICK_SEGMENT,
	STATE_PLACE_SEGMENT,
	STATE_SHOP,
	STATE_RESET,
}

var state := STATE_PICK_SEGMENT:
	set(v):
		state_changed.emit(state, v)
		state = v

signal state_changed(old: int, new: int)
