extends Node2D

const SCREEN_W := 1280.0
const SCREEN_H := 720.0
const GROUND_Y := 610.0
const PLAYER_X := 260.0

const GRAVITY := 1850.0
const JUMP_VELOCITY := -760.0
const BASE_SCROLL_SPEED := 280.0
const MAX_SCROLL_SPEED := 420.0

const GAME_TIME := 60.0
const PLAYER_HITBOX := Vector2(170, 130)

const TEX_HERO := "res://assets/pixel/v2/characters/tigergod_hero_v2/rotations/east.png"
const TEX_PET := "res://assets/pixel/v2/characters/pet_shiba_v2/rotations/east.png"
const TEX_BOSS := "res://assets/pixel/v2/characters/tigerboss_corrupted_v2/rotations/west.png"
const TEX_MOUNT := "res://assets/pixel/v2/objects/temple_palanquin_mount_v2.png"
const TEX_GROUND := "res://assets/pixel/v2/tilesets/sidescroller_ground_temple_v2.png"
const TEX_MAP_TILESET := "res://assets/pixel/v2/tilesets/taiwan_topdown_tileset_v1.png"

var _player_y := GROUND_Y - 110.0
var _player_vy := 0.0
var _is_on_ground := true

var _score := 0
var _hp := 5
var _time_left := GAME_TIME
var _run_time := 0.0
var _game_over := false

var _obstacle_timer := 0.0
var _collectible_timer := 0.0
var _next_obstacle_interval := 1.2
var _next_collectible_interval := 1.1
var _scroll_offset := 0.0

var _obstacles: Array[Dictionary] = []
var _collectibles: Array[Dictionary] = []

var _player_root: Node2D
var _mount_sprite: Sprite2D
var _hero_sprite: Sprite2D
var _pet_sprite: Sprite2D
var _boss_sprite: Sprite2D
var _background_map: Sprite2D

var _score_label: Label
var _hp_label: Label
var _timer_label: Label
var _state_label: Label

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_ensure_hud()
	_setup_camera()
	_setup_background()
	_setup_player()
	_setup_boss_preview()
	_build_ground_strip()
	_next_obstacle_interval = _rand_range(1.0, 1.8)
	_next_collectible_interval = _rand_range(0.9, 1.7)
	_update_hud()

func _process(delta: float) -> void:
	if _game_over:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return

	_run_time += delta
	_time_left = max(0.0, _time_left - delta)

	_handle_input()
	_update_player_physics(delta)
	_update_difficulty(delta)
	_update_spawners(delta)
	_update_entities(delta)
	_check_collisions()
	_update_hud()

	if _hp <= 0 or _time_left <= 0.0:
		_trigger_game_over()

func _handle_input() -> void:
	if (Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)) and _is_on_ground:
		_player_vy = JUMP_VELOCITY
		_is_on_ground = false

func _update_player_physics(delta: float) -> void:
	_player_vy += GRAVITY * delta
	_player_y += _player_vy * delta
	if _player_y >= GROUND_Y - 110.0:
		_player_y = GROUND_Y - 110.0
		_player_vy = 0.0
		_is_on_ground = true
	_player_root.position = Vector2(PLAYER_X, _player_y)

func _update_difficulty(delta: float) -> void:
	_scroll_offset += _current_scroll_speed() * delta
	if is_instance_valid(_background_map):
		_background_map.position.x = 1020.0 - _scroll_offset * 0.08

func _update_spawners(delta: float) -> void:
	_obstacle_timer += delta
	_collectible_timer += delta

	if _obstacle_timer >= _next_obstacle_interval:
		_obstacle_timer = 0.0
		_next_obstacle_interval = _rand_range(1.0, 1.8)
		_spawn_obstacle()
	if _collectible_timer >= _next_collectible_interval:
		_collectible_timer = 0.0
		_next_collectible_interval = _rand_range(0.9, 1.7)
		_spawn_collectible()

func _update_entities(delta: float) -> void:
	var speed := _current_scroll_speed()
	for item in _obstacles:
		var node: Node2D = item["node"]
		node.position.x -= speed * delta
	for item in _collectibles:
		var node: Node2D = item["node"]
		node.position.x -= speed * delta
		node.position.y += sin(_run_time * 4.0 + node.position.x * 0.01) * 0.4

	_prune_entities()

func _prune_entities() -> void:
	var kept_obstacles: Array[Dictionary] = []
	for item in _obstacles:
		var node: Node2D = item["node"]
		if node.position.x < -140.0:
			node.queue_free()
		else:
			kept_obstacles.append(item)
	_obstacles = kept_obstacles

	var kept_collectibles: Array[Dictionary] = []
	for item in _collectibles:
		var node: Node2D = item["node"]
		if node.position.x < -100.0:
			node.queue_free()
		else:
			kept_collectibles.append(item)
	_collectibles = kept_collectibles

func _check_collisions() -> void:
	var player_rect := Rect2(
		Vector2(PLAYER_X - PLAYER_HITBOX.x * 0.5, _player_y - PLAYER_HITBOX.y * 0.5),
		PLAYER_HITBOX
	)

	var hit_obstacles: Array[Dictionary] = []
	for item in _obstacles:
		var node: Node2D = item["node"]
		var size: Vector2 = item["size"]
		var rect := Rect2(node.position - size * 0.5, size)
		if rect.intersects(player_rect):
			hit_obstacles.append(item)

	for item in hit_obstacles:
		var node: Node2D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
		_obstacles.erase(item)
		_hp -= 1

	var grabbed_items: Array[Dictionary] = []
	for item in _collectibles:
		var node: Node2D = item["node"]
		var size: Vector2 = item["size"]
		var rect := Rect2(node.position - size * 0.5, size)
		if rect.intersects(player_rect):
			grabbed_items.append(item)

	for item in grabbed_items:
		var node: Node2D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
		_collectibles.erase(item)
		_score += 25

func _spawn_obstacle() -> void:
	var obstacle := Sprite2D.new()
	if _rng.randf() < 0.35:
		obstacle.texture = load(TEX_BOSS)
		obstacle.scale = Vector2(1.4, 1.4)
		obstacle.position = Vector2(SCREEN_W + 120.0, GROUND_Y - 75.0)
		add_child(obstacle)
		_obstacles.append({"node": obstacle, "size": Vector2(110, 100)})
		return

	var atlas := AtlasTexture.new()
	atlas.atlas = load(TEX_GROUND)
	atlas.region = Rect2(16, 16, 16, 16)
	obstacle.texture = atlas
	obstacle.scale = Vector2(4.0, 4.0)
	obstacle.position = Vector2(SCREEN_W + 80.0, GROUND_Y - 32.0)
	add_child(obstacle)
	_obstacles.append({"node": obstacle, "size": Vector2(64, 64)})

func _spawn_collectible() -> void:
	var collectible := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = load(TEX_MAP_TILESET)
	atlas.region = Rect2(32, 0, 16, 16)
	collectible.texture = atlas
	collectible.scale = Vector2(3.0, 3.0)
	collectible.position = Vector2(
		SCREEN_W + _rand_range(80.0, 220.0),
		_rand_range(280.0, GROUND_Y - 160.0)
	)
	add_child(collectible)
	_collectibles.append({"node": collectible, "size": Vector2(48, 48)})

func _current_scroll_speed() -> float:
	var progress: float = clampf(_run_time / GAME_TIME, 0.0, 1.0)
	return lerpf(BASE_SCROLL_SPEED, MAX_SCROLL_SPEED, progress)

func _trigger_game_over() -> void:
	_game_over = true
	_state_label.text = "Stage End - Score: %d  (Enter 重開)" % _score

func _setup_player() -> void:
	_player_root = Node2D.new()
	_player_root.position = Vector2(PLAYER_X, _player_y)
	add_child(_player_root)

	_mount_sprite = Sprite2D.new()
	_mount_sprite.texture = load(TEX_MOUNT)
	_mount_sprite.scale = Vector2(2.0, 2.0)
	_mount_sprite.position = Vector2(0, 12)
	_player_root.add_child(_mount_sprite)

	_hero_sprite = Sprite2D.new()
	_hero_sprite.texture = load(TEX_HERO)
	_hero_sprite.scale = Vector2(1.4, 1.4)
	_hero_sprite.position = Vector2(-8, -52)
	_player_root.add_child(_hero_sprite)

	_pet_sprite = Sprite2D.new()
	_pet_sprite.texture = load(TEX_PET)
	_pet_sprite.scale = Vector2(0.95, 0.95)
	_pet_sprite.position = Vector2(38, -36)
	_player_root.add_child(_pet_sprite)

func _setup_background() -> void:
	var sky := ColorRect.new()
	sky.color = Color("20263a")
	sky.position = Vector2.ZERO
	sky.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(sky)
	move_child(sky, 0)

	_background_map = Sprite2D.new()
	_background_map.texture = load(TEX_MAP_TILESET)
	_background_map.scale = Vector2(10.0, 10.0)
	_background_map.modulate = Color(0.9, 0.95, 1.0, 0.22)
	_background_map.position = Vector2(1020.0, 250.0)
	add_child(_background_map)

func _build_ground_strip() -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(TEX_GROUND)
	atlas.region = Rect2(0, 0, 16, 16)

	var tiles := int(SCREEN_W / 64.0) + 6
	for i in range(tiles):
		var spr := Sprite2D.new()
		spr.texture = atlas
		spr.scale = Vector2(4.0, 4.0)
		spr.position = Vector2(i * 64.0, GROUND_Y)
		add_child(spr)

func _setup_boss_preview() -> void:
	_boss_sprite = Sprite2D.new()
	_boss_sprite.texture = load(TEX_BOSS)
	_boss_sprite.scale = Vector2(1.9, 1.9)
	_boss_sprite.position = Vector2(SCREEN_W - 150.0, GROUND_Y - 92.0)
	_boss_sprite.modulate = Color(1, 1, 1, 0.55)
	add_child(_boss_sprite)

func _ensure_hud() -> void:
	var hud := get_node("HUD") as CanvasLayer
	var title := get_node_or_null("HUD/Title") as Label
	if title:
		title.text = "Tiger Boss Stage 1 Slice (V2 Art)"

	_score_label = Label.new()
	_score_label.position = Vector2(20, 64)
	hud.add_child(_score_label)

	_hp_label = Label.new()
	_hp_label.position = Vector2(20, 94)
	hud.add_child(_hp_label)

	_timer_label = Label.new()
	_timer_label.position = Vector2(20, 124)
	hud.add_child(_timer_label)

	_state_label = Label.new()
	_state_label.position = Vector2(20, 154)
	hud.add_child(_state_label)

	var tips := Label.new()
	tips.position = Vector2(20, SCREEN_H - 36)
	tips.text = "Space/Enter 跳躍, Enter 可重開"
	hud.add_child(tips)

func _update_hud() -> void:
	_score_label.text = "Score: %d" % _score
	_hp_label.text = "HP: %d" % _hp
	_timer_label.text = "Time: %d" % int(ceil(_time_left))
	if not _game_over:
		_state_label.text = "速度: %d" % int(_current_scroll_speed())

func _setup_camera() -> void:
	var cam := get_node("Camera2D") as Camera2D
	cam.position = Vector2(SCREEN_W * 0.5, SCREEN_H * 0.5)
	cam.zoom = Vector2.ONE

func _rand_range(min_v: float, max_v: float) -> float:
	return _rng.randf_range(min_v, max_v)
