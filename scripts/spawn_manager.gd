class_name SpawnManager
extends RefCounted

var _rng: RandomNumberGenerator
var _obstacle_timer: float = 0.0
var _collectible_timer: float = 0.0
var _next_obstacle_interval: float = 1.4
var _next_collectible_interval: float = 1.2

func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng
	_next_obstacle_interval = _rng.randf_range(1.0, 1.8)
	_next_collectible_interval = _rng.randf_range(0.9, 1.7)

func update(delta: float) -> Dictionary:
	_obstacle_timer += delta
	_collectible_timer += delta

	var spawn_obstacle: bool = false
	var spawn_collectible: bool = false

	if _obstacle_timer >= _next_obstacle_interval:
		_obstacle_timer = 0.0
		_next_obstacle_interval = _rng.randf_range(1.0, 1.8)
		spawn_obstacle = true

	if _collectible_timer >= _next_collectible_interval:
		_collectible_timer = 0.0
		_next_collectible_interval = _rng.randf_range(0.9, 1.7)
		spawn_collectible = true

	return {
		"obstacle": spawn_obstacle,
		"collectible": spawn_collectible,
	}
