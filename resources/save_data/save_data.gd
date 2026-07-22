class_name Save extends Resource
@export_group("Visual")
@export var fullscreen: bool = false
@export var vsync: bool = true
@export_group("Audio")
@export var vol_sfx: float = .75
@export var vol_music: float = .75


static var data: Save
const PATH := "user://save.tres"

func save() -> Error:
	return ResourceSaver.save(data, PATH)

func fetch() -> Save:
	if data: return data

	if ResourceLoader.exists(PATH):
		data = load(PATH)
	else: data = new()
	return data
