extends Node2D
const GameSession = preload("res://scripts/game_session.gd")
const SpawnManager = preload("res://scripts/spawn_manager.gd")
const PixTextureLoader = preload("res://scripts/pix_texture_loader.gd")
const UIStyle = preload("res://scripts/ui_style.gd")
const HeroAnimTemp = preload("res://scripts/hero_animation_temp.gd")

const SCREEN_W: float = 1280.0
const SCREEN_H: float = 720.0
const GROUND_Y: float = 610.0
const PLAYER_X: float = 260.0

const GRAVITY: float = 1850.0
const JUMP_VELOCITY: float = -760.0
const BASE_SCROLL_SPEED: float = 280.0
const MAX_SCROLL_SPEED: float = 420.0

const PLAYER_HITBOX: Vector2 = Vector2(170, 130)

const TEX_HERO: String = "res://assets/pixel/v2/characters/tigergod_hero_v2/rotations/east.png"
const TEX_PET: String = "res://assets/pixel/v2/characters/pet_shiba_v2/rotations/east.png"
const TEX_BOSS: String = "res://assets/pixel/v2/characters/tigerboss_corrupted_v2/rotations/west.png"
const TEX_MOUNT: String = "res://assets/pixel/v2/objects/temple_palanquin_mount_v2.png"
const TEX_GROUND: String = "res://assets/pixel/v2/tilesets/sidescroller_ground_temple_v2.png"
const TEX_MAP_TILESET: String = "res://assets/pixel/v2/tilesets/taiwan_topdown_tileset_v1.png"

const OBSTACLE_TILES: Array[String] = [
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_0.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_1.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_2.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_3.png",
]

const ITEM_TILES: Array[String] = [
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_4.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_5.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_6.png",
	"res://assets/pixel/v2/tiles_pro_60fcef1c/tile_7.png",
]

const OBSTACLE_SCALES: Array[float] = [2.3, 2.8, 2.5, 2.2]
const OBSTACLE_HITBOXES: Array[Vector2] = [
	Vector2(54, 38),
	Vector2(72, 56),
	Vector2(60, 48),
	Vector2(58, 24),
]
const OBSTACLE_HITBOX_OFFSETS: Array[Vector2] = [
	Vector2(0, 10),
	Vector2(0, 6),
	Vector2(0, 4),
	Vector2(0, 8),
]
const OBSTACLE_Y_OFFSETS: Array[float] = [10.0, 28.0, 24.0, 8.0]

const ITEM_SCALES: Array[float] = [2.0, 2.1, 2.0, 2.0]
const ITEM_HITBOXES: Array[Vector2] = [
	Vector2(34, 34),
	Vector2(34, 34),
	Vector2(36, 36),
	Vector2(34, 34),
]
const ITEM_HITBOX_OFFSETS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 2),
]
const ITEM_Y_OFFSETS: Array[float] = [0.0, 4.0, -2.0, 2.0]

var _player_y: float = GROUND_Y - 110.0
var _player_vy: float = 0.0
var _is_on_ground: bool = true
var _run_time: float = 0.0
var _game_over: bool = false

var _scroll_offset: float = 0.0
var _obstacles: Array[Dictionary] = []
var _collectibles: Array[Dictionary] = []
var _obstacle_textures: Array[Texture2D] = []
var _item_textures: Array[Texture2D] = []
var _boss_attack_timer: float = 0.0
var _next_boss_attack: float = 4.0
var _telegraph_timer: float = 0.0

var _player_root: Node2D
var _hero: Sprite2D  # 主角sprite（用於動畫）
var _hero_animator: HeroAnimTemp  # 臨時動畫控制器
var _background_map: Sprite2D
var _telegraph: ColorRect

var _score_label: Label
var _hp_label: Label
var _timer_label: Label
var _state_label: Label

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _spawn_manager: SpawnManager

func _ready() -> void:
	_rng.randomize()
	_spawn_manager = SpawnManager.new(_rng)
	_load_tile_textures()
	_ensure_hud()
	_setup_camera()
	_setup_background()
	_setup_player()
	_setup_boss_preview()
	_setup_telegraph()
	_build_ground_strip()
	_update_hud()

func _process(delta: float) -> void:
	if _game_over:
		if Input.is_action_just_pressed("ui_accept"):
			GameSession.reset_run()
			get_tree().change_scene_to_file("res://scenes/result.tscn")
		return

	_run_time += delta
	GameSession.time_left = max(0.0, GameSession.time_left - delta)

	_handle_input()
	_update_player_physics(delta)
	_update_hero_animation(delta)  # 🦞 臨時動畫
	_update_scroll(delta)
	_update_spawners(delta)
	_update_boss_attack(delta)
	_update_entities(delta)
	_check_collisions()
	_update_hud()

	if GameSession.hp <= 0 or GameSession.time_left <= 0.0:
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

func _update_hero_animation(delta: float) -> void:
	if _hero_animator and not _game_over:
		_hero_animator.animate(delta)

func _update_scroll(delta: float) -> void:
	_scroll_offset += _current_scroll_speed() * delta
	if is_instance_valid(_background_map):
		_background_map.position.x = 1020.0 - _scroll_offset * 0.08

func _update_spawners(delta: float) -> void:
	var spawned: Dictionary = _spawn_manager.update(delta)
	if bool(spawned.get("obstacle", false)):
		_spawn_obstacle()
	if bool(spawned.get("collectible", false)):
		_spawn_collectible()

func _update_boss_attack(delta: float) -> void:
	_boss_attack_timer += delta
	if _telegraph_timer > 0.0:
		_telegraph_timer -= delta
		_telegraph.modulate.a = 0.25 + 0.45 * abs(sin(_run_time * 15.0))
		if _telegraph_timer <= 0.0:
			_telegraph.visible = false

	if _boss_attack_timer >= _next_boss_attack:
		_boss_attack_timer = 0.0
		_next_boss_attack = _rng.randf_range(3.2, 5.4)
		_telegraph_timer = 0.75
		_telegraph.visible = true
		_state_label.text = "Boss 前搖! 準備跳躍"

func _update_entities(delta: float) -> void:
	var speed: float = _current_scroll_speed()
	for item: Dictionary in _obstacles:
		var node: Node2D = item["node"]
		node.position.x -= speed * delta
	for item: Dictionary in _collectibles:
		var node: Node2D = item["node"]
		node.position.x -= speed * delta
		node.position.y += sin(_run_time * 4.0 + node.position.x * 0.01) * 0.4
	_prune_entities()

func _prune_entities() -> void:
	var kept_obstacles: Array[Dictionary] = []
	for item: Dictionary in _obstacles:
		var node: Node2D = item["node"]
		if node.position.x < -140.0:
			node.queue_free()
		else:
			kept_obstacles.append(item)
	_obstacles = kept_obstacles

	var kept_collectibles: Array[Dictionary] = []
	for item: Dictionary in _collectibles:
		var node: Node2D = item["node"]
		if node.position.x < -100.0:
			node.queue_free()
		else:
			kept_collectibles.append(item)
	_collectibles = kept_collectibles

func _check_collisions() -> void:
	var player_rect: Rect2 = Rect2(
		Vector2(PLAYER_X - PLAYER_HITBOX.x * 0.5, _player_y - PLAYER_HITBOX.y * 0.5),
		PLAYER_HITBOX
	)

	var hit_obstacles: Array[Dictionary] = []
	for item: Dictionary in _obstacles:
		var node: Node2D = item["node"]
		var size: Vector2 = item["size"]
		var offset: Vector2 = item.get("offset", Vector2.ZERO)
		var rect: Rect2 = Rect2(node.position + offset - size * 0.5, size)
		if rect.intersects(player_rect):
			hit_obstacles.append(item)

	for item: Dictionary in hit_obstacles:
		var node: Node2D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
		_obstacles.erase(item)
		GameSession.hp -= 1
		GameSession.hits_taken += 1

	var grabbed_items: Array[Dictionary] = []
	for item: Dictionary in _collectibles:
		var node: Node2D = item["node"]
		var size: Vector2 = item["size"]
		var offset: Vector2 = item.get("offset", Vector2.ZERO)
		var rect: Rect2 = Rect2(node.position + offset - size * 0.5, size)
		if rect.intersects(player_rect):
			grabbed_items.append(item)

	for item: Dictionary in grabbed_items:
		var node: Node2D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
		_collectibles.erase(item)
		GameSession.score += 25
		GameSession.collected_count += 1

func _spawn_obstacle() -> void:
	var obstacle: Sprite2D = Sprite2D.new()
	if _rng.randf() < 0.35:
		obstacle.texture = PixTextureLoader.load_png(TEX_BOSS)
		obstacle.scale = Vector2(1.4, 1.4)
		obstacle.position = Vector2(SCREEN_W + 120.0, GROUND_Y - 75.0)
		add_child(obstacle)
		_obstacles.append({"node": obstacle, "size": Vector2(110, 100), "offset": Vector2.ZERO})
		return

	var pick: int = _rng.randi() % _obstacle_textures.size()
	obstacle.texture = _obstacle_textures[pick]
	obstacle.scale = Vector2.ONE * OBSTACLE_SCALES[pick]
	obstacle.position = Vector2(SCREEN_W + 80.0, GROUND_Y - OBSTACLE_Y_OFFSETS[pick])
	add_child(obstacle)
	_obstacles.append({
		"node": obstacle,
		"size": OBSTACLE_HITBOXES[pick],
		"offset": OBSTACLE_HITBOX_OFFSETS[pick],
	})

func _spawn_collectible() -> void:
	var collectible: Sprite2D = Sprite2D.new()
	var pick: int = _rng.randi() % _item_textures.size()
	collectible.texture = _item_textures[pick]
	collectible.scale = Vector2.ONE * ITEM_SCALES[pick]
	collectible.position = Vector2(
		SCREEN_W + _rng.randf_range(80.0, 220.0),
		_rng.randf_range(280.0, GROUND_Y - 160.0) + ITEM_Y_OFFSETS[pick]
	)
	add_child(collectible)
	_collectibles.append({
		"node": collectible,
		"size": ITEM_HITBOXES[pick],
		"offset": ITEM_HITBOX_OFFSETS[pick],
	})
	GameSession.spawned_collectibles += 1

func _current_scroll_speed() -> float:
	var progress: float = clampf(_run_time / 60.0, 0.0, 1.0)
	return lerpf(BASE_SCROLL_SPEED, MAX_SCROLL_SPEED, progress)

func _trigger_game_over() -> void:
	_game_over = true
	GameSession.cleared = GameSession.time_left <= 0.0 and GameSession.hp > 0
	_state_label.text = "Stage End - Score: %d (Enter 結算)" % GameSession.score

func _setup_player() -> void:
	_player_root = Node2D.new()
	_player_root.position = Vector2(PLAYER_X, _player_y)
	add_child(_player_root)

	var mount: Sprite2D = Sprite2D.new()
	mount.texture = PixTextureLoader.load_png(TEX_MOUNT)
	mount.scale = Vector2(2.0, 2.0)
	mount.position = Vector2(0, 12)
	_player_root.add_child(mount)

	_hero = Sprite2D.new()
	_hero.texture = PixTextureLoader.load_png(TEX_HERO)
	_hero.scale = Vector2(1.4, 1.4)
	_hero.position = Vector2(-8, -52)
	_player_root.add_child(_hero)
	
	# 初始化臨時動畫控制器
	_hero_animator = HeroAnimTemp.new()
	_hero_animator.setup(_hero, -52)

	var pet: Sprite2D = Sprite2D.new()
	pet.texture = PixTextureLoader.load_png(TEX_PET)
	pet.scale = Vector2(0.95, 0.95)
	pet.position = Vector2(38, -36)
	_player_root.add_child(pet)

func _setup_background() -> void:
	var sky: ColorRect = ColorRect.new()
	sky.color = Color("20263a")
	sky.position = Vector2.ZERO
	sky.size = Vector2(SCREEN_W, SCREEN_H)
	add_child(sky)
	move_child(sky, 0)

	_background_map = Sprite2D.new()
	_background_map.texture = PixTextureLoader.load_png(TEX_MAP_TILESET)
	_background_map.scale = Vector2(10.0, 10.0)
	_background_map.modulate = Color(0.9, 0.95, 1.0, 0.22)
	_background_map.position = Vector2(1020.0, 250.0)
	add_child(_background_map)

func _build_ground_strip() -> void:
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = PixTextureLoader.load_png(TEX_GROUND)
	atlas.region = Rect2(0, 0, 16, 16)
	var tiles: int = int(SCREEN_W / 64.0) + 6
	for i: int in range(tiles):
		var spr: Sprite2D = Sprite2D.new()
		spr.texture = atlas
		spr.scale = Vector2(4.0, 4.0)
		spr.position = Vector2(float(i) * 64.0, GROUND_Y)
		add_child(spr)

func _setup_boss_preview() -> void:
	var boss: Sprite2D = Sprite2D.new()
	boss.texture = PixTextureLoader.load_png(TEX_BOSS)
	boss.scale = Vector2(1.9, 1.9)
	boss.position = Vector2(SCREEN_W - 150.0, GROUND_Y - 92.0)
	boss.modulate = Color(1, 1, 1, 0.55)
	add_child(boss)

func _setup_telegraph() -> void:
	_telegraph = ColorRect.new()
	_telegraph.color = Color(1.0, 0.2, 0.2, 0.5)
	_telegraph.size = Vector2(210, 140)
	_telegraph.position = Vector2(PLAYER_X - 105.0, GROUND_Y - 190.0)
	_telegraph.visible = false
	add_child(_telegraph)

func _ensure_hud() -> void:
	var hud: CanvasLayer = get_node("HUD") as CanvasLayer
	var title: Label = get_node_or_null("HUD/Title") as Label
	if title:
		title.text = "Run Stage - V2 Artwork"
		UIStyle.style_title(title)

	var panel: ColorRect = UIStyle.create_panel(Vector2(420, 220), Vector2(12, 40))
	panel.z_index = -1
	hud.add_child(panel)

	_score_label = Label.new()
	_score_label.position = Vector2(20, 64)
	UIStyle.style_sub(_score_label)
	hud.add_child(_score_label)

	_hp_label = Label.new()
	_hp_label.position = Vector2(20, 94)
	UIStyle.style_sub(_hp_label)
	hud.add_child(_hp_label)

	_timer_label = Label.new()
	_timer_label.position = Vector2(20, 124)
	UIStyle.style_sub(_timer_label)
	hud.add_child(_timer_label)

	_state_label = Label.new()
	_state_label.position = Vector2(20, 154)
	UIStyle.style_sub(_state_label)
	hud.add_child(_state_label)

	var tips: Label = Label.new()
	tips.position = Vector2(20, SCREEN_H - 36)
	tips.text = "Space/Enter 跳躍，紅框=Boss 前搖，結束後 Enter 到 Result"
	UIStyle.style_tip(tips)
	hud.add_child(tips)

func _update_hud() -> void:
	_score_label.text = "Score: %d" % GameSession.score
	_hp_label.text = "HP: %d" % GameSession.hp
	_timer_label.text = "Time: %d" % int(ceil(GameSession.time_left))
	if not _game_over:
		_state_label.text = "速度: %d | %s + %s" % [
			int(_current_scroll_speed()),
			GameSession.mount_name,
			GameSession.pet_name,
		]

func _setup_camera() -> void:
	var cam: Camera2D = get_node("Camera2D") as Camera2D
	cam.position = Vector2(SCREEN_W * 0.5, SCREEN_H * 0.5)
	cam.zoom = Vector2.ONE

func _load_tile_textures() -> void:
	for path: String in OBSTACLE_TILES:
		var tex: Texture2D = PixTextureLoader.load_png(path)
		if tex:
			_obstacle_textures.append(tex)
	for path: String in ITEM_TILES:
		var tex: Texture2D = PixTextureLoader.load_png(path)
		if tex:
			_item_textures.append(tex)
