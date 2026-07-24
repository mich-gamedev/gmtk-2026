class_name BossInfo extends Resource

@export_group("Visual")
@export var fx_radius: float = 16
@export_group("Logic")
@export var rand_weight: float = 1
@export var scene: PackedScene
@export var count: int = 1

static var infos: Array[BossInfo]
static var info_weights: PackedFloat32Array

static func setup() -> void:
	if infos.is_empty():
		for i in DirAccess.get_directories_at("res://objects/bosses/"):
			infos.append(load("res://objects/bosses/".path_join(i).path_join("boss.tres")))
	if info_weights.is_empty():
		for i in infos:
			info_weights.append(i.rand_weight)

static func get_random() -> BossInfo:
	var rng := RandomNumberGenerator.new()
	return infos[rng.rand_weighted(info_weights)]
