extends SceneTree

var _scenes: Array[String] = [
	"res://scenes/title.tscn",
	"res://scenes/map.tscn",
	"res://scenes/selection.tscn",
	"res://scenes/run_stage.tscn",
	"res://scenes/result.tscn",
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path: String in _scenes:
		var err: int = change_scene_to_file(path)
		if err != OK:
			push_error("Scene switch failed: %s err=%d" % [path, err])
			quit(1)
			return
		print("loaded:", path)
		await process_frame
		await process_frame
	print("smoke_test:ok")
	quit(0)
