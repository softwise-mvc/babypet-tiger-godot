extends Node2D

var _tip: Label
var _pulse_time: float = 0.0
var _cat: Sprite2D
var _cat_origin_y: float
var _stars: Array = []

func _ready() -> void:
	_tip = get_node("HUD/Tip") as Label
	_setup_smoke_shader()
	_setup_cat()
	_setup_stars()

func _setup_smoke_shader() -> void:
	var bg := get_node("BG") as Sprite2D
	var shader_code := """
shader_type canvas_item;

uniform float speed : hint_range(0.1, 3.0) = 1.0;
uniform float strength : hint_range(0.0, 0.02) = 0.006;

void fragment() {
	vec2 uv = UV;

	// 只對煙的區域做波動（中央細長區域）
	float smoke_x_center = 0.498;
	float smoke_x_width = 0.022;
	float smoke_y_top = 0.43;
	float smoke_y_bottom = 0.58;

	float in_smoke_x = smoothstep(smoke_x_width, 0.0,
		abs(uv.x - smoke_x_center));
	float in_smoke_y = smoothstep(smoke_y_top - 0.04, smoke_y_top, uv.y)
		* smoothstep(smoke_y_bottom + 0.04, smoke_y_bottom, uv.y);

	float mask = in_smoke_x * in_smoke_y;

	// 多層波形疊加，煙的搖曳感
	float wave = sin(uv.y * 18.0 - TIME * speed * 2.2) * 0.5
			   + sin(uv.y * 9.0  - TIME * speed * 1.3) * 0.3
			   + sin(uv.y * 5.0  - TIME * speed * 0.8) * 0.2;

	uv.x += wave * strength * mask;
	COLOR = texture(TEXTURE, uv);
}
"""
	var shader := Shader.new()
	shader.code = shader_code
	var mat := ShaderMaterial.new()
	mat.shader = shader
	bg.material = mat

func _setup_cat() -> void:
	_cat = get_node_or_null("North") as Sprite2D
	if _cat:
		_cat_origin_y = _cat.position.y

func _setup_stars() -> void:
	# 在天空區域隨機產生幾個閃爍星星 Label
	var hud := get_node("HUD") as CanvasLayer
	var star_positions := [
		Vector2(580, 45), Vector2(660, 30), Vector2(740, 60),
		Vector2(820, 25), Vector2(900, 50), Vector2(1050, 35),
		Vector2(1150, 55), Vector2(1200, 30), Vector2(1300, 65),
	]
	for pos in star_positions:
		var lbl := Label.new()
		lbl.text = "✦"
		lbl.position = pos
		lbl.add_theme_font_size_override("font_size", randi_range(10, 18))
		lbl.add_theme_color_override("font_color", Color(1, 1, 0.8, 1.0))
		hud.add_child(lbl)
		_stars.append(lbl)

func _process(delta: float) -> void:
	_pulse_time += delta

	# 提示文字閃爍
	_tip.modulate.a = 0.55 + 0.45 * abs(sin(_pulse_time * 2.8))

	# 貓咪上下漂浮
	if _cat:
		_cat.position.y = _cat_origin_y + sin(_pulse_time * 1.8) * 5.0

	# 星星閃爍（每顆偏移不同相位）
	for i in _stars.size():
		var lbl: Label = _stars[i]
		var phase := float(i) * 0.7
		lbl.modulate.a = 0.3 + 0.7 * abs(sin(_pulse_time * 1.5 + phase))

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/map.tscn")
