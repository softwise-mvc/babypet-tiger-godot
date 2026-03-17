extends Node2D
const GameSession = preload("res://scripts/game_session.gd")
const PixTextureLoader = preload("res://scripts/pix_texture_loader.gd")
const UIStyle = preload("res://scripts/ui_style.gd")
const TEX_MOUNT: String = "res://assets/pixel/v2/objects/temple_palanquin_mount_v2.png"
const TEX_PET: String = "res://assets/pixel/v2/characters/pet_shiba_v2/rotations/east.png"

var _mounts: Array[String] = ["Temple Palanquin", "Prince Scooter", "Tiger Back"]
var _pets: Array[String] = ["Shiba", "Tabby", "Lucky Dog"]
var _mount_idx: int = 0
var _pet_idx: int = 0
var _mount_sprite: Sprite2D
var _pet_sprite: Sprite2D

func _ready() -> void:
	var panel: Control = UIStyle.create_panel_frame(Vector2(930, 360), Vector2(70, 400), Color("1a1322"))
	add_child(panel)

	_mount_sprite = Sprite2D.new()
	_mount_sprite.texture = PixTextureLoader.load_png(TEX_MOUNT)
	_mount_sprite.position = Vector2(860, 290)
	_mount_sprite.scale = Vector2(2.4, 2.4)
	add_child(_mount_sprite)

	_pet_sprite = Sprite2D.new()
	_pet_sprite.texture = PixTextureLoader.load_png(TEX_PET)
	_pet_sprite.position = Vector2(860, 460)
	_pet_sprite.scale = Vector2(2.2, 2.2)
	add_child(_pet_sprite)

	_update_labels()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		_mount_idx = (_mount_idx - 1 + _mounts.size()) % _mounts.size()
		_update_labels()
	if Input.is_action_just_pressed("ui_right"):
		_mount_idx = (_mount_idx + 1) % _mounts.size()
		_update_labels()
	if Input.is_action_just_pressed("ui_up"):
		_pet_idx = (_pet_idx - 1 + _pets.size()) % _pets.size()
		_update_labels()
	if Input.is_action_just_pressed("ui_down"):
		_pet_idx = (_pet_idx + 1) % _pets.size()
		_update_labels()
	if Input.is_action_just_pressed("ui_accept"):
		GameSession.mount_name = _mounts[_mount_idx]
		GameSession.pet_name = _pets[_pet_idx]
		GameSession.reset_run()
		get_tree().change_scene_to_file("res://scenes/run_stage.tscn")

func _update_labels() -> void:
	var title_label: Label = get_node("HUD/Title") as Label
	title_label.text = "Mount/Pet Selection"
	UIStyle.style_title(title_label)

	var mount_label: Label = get_node("HUD/Mount") as Label
	mount_label.text = "Mount: %s" % _mounts[_mount_idx]
	UIStyle.style_sub(mount_label)

	var pet_label: Label = get_node("HUD/Pet") as Label
	pet_label.text = "Pet: %s" % _pets[_pet_idx]
	UIStyle.style_sub(pet_label)

	var tip_label: Label = get_node("HUD/Tip") as Label
	tip_label.text = "左右切坐騎，上下切寵物，Enter 開跑\n加成: %s / %s" % [_mount_bonus(), _pet_bonus()]
	UIStyle.style_tip(tip_label)
	_mount_sprite.modulate = _mount_color()
	_pet_sprite.modulate = _pet_color()

func _mount_bonus() -> String:
	match _mount_idx:
		0:
			return "均衡（無額外懲罰）"
		1:
			return "速度 +12%"
		2:
			return "虎爺能量回復 +15%"
	return "均衡"

func _pet_bonus() -> String:
	match _pet_idx:
		0:
			return "收集分數 +5"
		1:
			return "受傷減免（首次-0）"
		2:
			return "Near Miss 分數 +10"
	return "無"

func _mount_color() -> Color:
	match _mount_idx:
		0:
			return Color(1, 1, 1, 1)
		1:
			return Color("ffb74d")
		2:
			return Color("ffd54f")
	return Color.WHITE

func _pet_color() -> Color:
	match _pet_idx:
		0:
			return Color(1, 1, 1, 1)
		1:
			return Color("ffcc80")
		2:
			return Color("fff59d")
	return Color.WHITE
