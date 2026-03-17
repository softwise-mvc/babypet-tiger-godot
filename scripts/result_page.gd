extends Node2D
const GameSession = preload("res://scripts/game_session.gd")
const UIStyle = preload("res://scripts/ui_style.gd")

func _ready() -> void:
	var title: Label = get_node("HUD/Title") as Label
	title.text = "Result"
	UIStyle.style_title(title)

	var panel: Control = UIStyle.create_panel_frame(Vector2(520, 260), Vector2(30, 100), Color("171321"))
	panel.z_index = -1
	get_node("HUD").add_child(panel)

	var score: Label = get_node("HUD/Score") as Label
	score.text = "Score: %d" % GameSession.score
	UIStyle.style_sub(score)

	var hp: Label = get_node("HUD/Hp") as Label
	hp.text = "HP Left: %d  | Hits Taken: %d" % [GameSession.hp, GameSession.hits_taken]
	UIStyle.style_sub(hp)

	var collect_rate: int = 0
	if GameSession.spawned_collectibles > 0:
		collect_rate = int(round(float(GameSession.collected_count) / float(GameSession.spawned_collectibles) * 100.0))
	var time: Label = get_node("HUD/Time") as Label
	time.text = "Time Left: %d  | Collect Rate: %d%%" % [int(ceil(GameSession.time_left)), collect_rate]
	UIStyle.style_sub(time)

	var tip: Label = get_node("HUD/Tip") as Label
	var state: String = "通關成功" if GameSession.cleared else "挑戰失敗"
	tip.text = "%s | Enter 回地圖 | Space 再戰同關" % state
	UIStyle.style_tip(tip)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		GameSession.reset_run()
		get_tree().change_scene_to_file("res://scenes/run_stage.tscn")
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/map.tscn")
