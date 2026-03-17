extends Node2D
const GameSession = preload("res://scripts/game_session.gd")
const UIStyle = preload("res://scripts/ui_style.gd")

var _stage_label: Label
var _route_line: Line2D
var _stage_nodes: Array[ColorRect] = []
var _node_points: Array[Vector2] = []

func _ready() -> void:
	var title: Label = get_node("HUD/Title") as Label
	title.text = "Taiwan Route Map"
	UIStyle.style_title(title)
	_stage_label = get_node("HUD/Stage") as Label
	UIStyle.style_sub(_stage_label)
	var tip: Label = get_node("HUD/Tip") as Label
	tip.text = "左右鍵切換關卡，Enter 前往選擇"
	UIStyle.style_tip(tip)
	_build_route_visual()
	_refresh_stage_ui()

func _build_route_visual() -> void:
	_node_points = [
		Vector2(260, 120), Vector2(300, 160), Vector2(340, 200),
		Vector2(380, 240), Vector2(420, 280), Vector2(460, 320),
		Vector2(500, 360), Vector2(540, 400), Vector2(580, 440),
		Vector2(620, 480), Vector2(680, 520), Vector2(740, 550),
		Vector2(800, 570), Vector2(860, 590), Vector2(920, 610),
	]

	_route_line = Line2D.new()
	_route_line.default_color = Color("f8d278")
	_route_line.width = 6.0
	for p: Vector2 in _node_points:
		_route_line.add_point(p)
	var panel: Control = UIStyle.create_panel_frame(Vector2(760, 260), Vector2(220, 110), Color("1e1a2a"))
	add_child(panel)
	add_child(_route_line)

	for i: int in range(_node_points.size()):
		var node: ColorRect = ColorRect.new()
		node.size = Vector2(18, 18)
		node.position = _node_points[i] - node.size * 0.5
		add_child(node)
		_stage_nodes.append(node)

func _refresh_stage_ui() -> void:
	_stage_label.text = "目前關卡: Stage %d / 15" % GameSession.stage_id
	for i: int in range(_stage_nodes.size()):
		var n: ColorRect = _stage_nodes[i]
		if i + 1 < GameSession.stage_id:
			n.color = Color("7ccf6b")
		elif i + 1 == GameSession.stage_id:
			n.color = Color("ffcc4d")
		else:
			n.color = Color("5a6270")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		GameSession.stage_id = max(1, GameSession.stage_id - 1)
		_refresh_stage_ui()
	if Input.is_action_just_pressed("ui_right"):
		GameSession.stage_id = min(15, GameSession.stage_id + 1)
		_refresh_stage_ui()
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/selection.tscn")
