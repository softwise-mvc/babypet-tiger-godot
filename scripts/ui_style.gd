class_name UIStyle
extends Resource

const TITLE_COLOR: Color = Color("ffd97a")
const SUB_COLOR: Color = Color("ffffff")
const TIP_COLOR: Color = Color("cddcff")
const PANEL_COLOR: Color = Color("130f1f")
const BORDER_COLOR: Color = Color("f8d278")
const ACCENT_COLOR: Color = Color("d56a3a")
const APP_THEME: Theme = preload("res://assets/ui/app_theme.tres")

static func style_title(label: Label) -> void:
	label.theme = APP_THEME
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_outline_color", Color("1a0000"))
	label.add_theme_color_override("font_color", Color("CC2200"))

static func style_sub(label: Label) -> void:
	label.theme = APP_THEME
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_color_override("font_outline_color", Color("15111c"))
	label.modulate = SUB_COLOR

static func style_tip(label: Label) -> void:
	label.theme = APP_THEME
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color("1a0000"))
	label.add_theme_color_override("font_color", Color("FFB800"))

static func create_panel(size: Vector2, pos: Vector2) -> ColorRect:
	var panel: ColorRect = ColorRect.new()
	panel.color = PANEL_COLOR
	panel.size = size
	panel.position = pos
	return panel

static func create_panel_frame(size: Vector2, pos: Vector2, tint: Color = PANEL_COLOR) -> Control:
	var root: Control = Control.new()
	root.position = pos
	root.size = size

	var fill: ColorRect = ColorRect.new()
	fill.color = tint
	fill.size = size
	root.add_child(fill)

	var inset: ColorRect = ColorRect.new()
	inset.color = tint.lightened(0.06)
	inset.position = Vector2(6, 6)
	inset.size = size - Vector2(12, 12)
	root.add_child(inset)

	var top_line: ColorRect = ColorRect.new()
	top_line.color = BORDER_COLOR
	top_line.size = Vector2(size.x, 3)
	root.add_child(top_line)

	var bottom_line: ColorRect = ColorRect.new()
	bottom_line.color = ACCENT_COLOR
	bottom_line.position = Vector2(0, size.y - 3)
	bottom_line.size = Vector2(size.x, 3)
	root.add_child(bottom_line)

	return root
