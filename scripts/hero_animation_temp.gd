extends Node2D
## 臨時程式化動畫 — 在 PixelLab 動畫到位前使用

var _cycle_time: float = 0.0
var _base_y: float = 0.0
var _sprite: Sprite2D

func setup(sprite: Sprite2D, base_y: float) -> void:
	_sprite = sprite
	_base_y = base_y

func animate(delta: float) -> void:
	if not _sprite:
		return
	
	_cycle_time += delta * 10.0  # 跑步頻率
	
	# 上下彈跳（模擬跑步起伏）
	var bob_offset: float = abs(sin(_cycle_time)) * 8.0
	_sprite.position.y = _base_y - bob_offset
	
	# 輕微傾斜（動態感）
	_sprite.rotation_degrees = sin(_cycle_time * 0.5) * 4.0
	
	# 縮放變化（步伐節奏）
	var scale_pulse: float = 1.0 + sin(_cycle_time) * 0.08
	_sprite.scale = Vector2(scale_pulse, scale_pulse)
	
	# 水平微調（視覺衝刺感）
	_sprite.offset.x = sin(_cycle_time * 2.0) * 2.0
