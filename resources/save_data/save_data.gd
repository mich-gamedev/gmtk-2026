class_name Save extends Resource
@export_group("Visual")
@export var fullscreen: bool = false
@export var vsync: bool = true
@export var rotate_world: bool = true
@export_group("Audio")
@export var vol_sfx: float = .75
@export var vol_music: float = .75
@export_group("Game")
@export var high_score: int


static var data: Save
const PATH := "user://save.tres"

static func save() -> Error:
	return ResourceSaver.save(fetch(), PATH)

static func fetch() -> Save:
	if data: return data

	if ResourceLoader.exists(PATH):
		data = load(PATH)
	else: data = new()
	return data
