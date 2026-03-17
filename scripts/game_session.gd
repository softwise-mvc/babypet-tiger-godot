class_name GameSession
extends RefCounted

static var stage_id: int = 1
static var hp: int = 5
static var score: int = 0
static var time_left: float = 60.0
static var mount_name: String = "Temple Palanquin"
static var pet_name: String = "Shiba"
static var hits_taken: int = 0
static var collected_count: int = 0
static var spawned_collectibles: int = 0
static var cleared: bool = false

static func reset_run() -> void:
	hp = 5
	score = 0
	time_left = 60.0
	hits_taken = 0
	collected_count = 0
	spawned_collectibles = 0
	cleared = false
