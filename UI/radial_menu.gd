extends CanvasLayer

signal action_selected(action_id: String)

const RADIUS   = 68.0
const BTN_DIAM = 38.0

@onready var _backdrop:  Button  = $Backdrop
@onready var _container: Control = $Container

func _ready() -> void:
	_backdrop.pressed.connect(_close)
	var empty = StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		_backdrop.add_theme_stylebox_override(state, empty)

func show_at(screen_pos: Vector2, items: Array) -> void:
	_build(items)
	_container.position = screen_pos
	_backdrop.size = get_viewport().get_visible_rect().size
	visible = true

func _close() -> void:
	visible = false

func _build(items: Array) -> void:
	for c in _container.get_children():
		c.queue_free()
	var n = items.size()
	for i in range(n):
		var a   = -PI / 2.0 + 2.0 * PI * i / float(n)
		var off = Vector2(cos(a), sin(a)) * RADIUS
		var btn = _make_btn(items[i])
		btn.position = off - Vector2(BTN_DIAM, BTN_DIAM) / 2.0
		_container.add_child(btn)

func _make_btn(item: Dictionary) -> Button:
	var btn = Button.new()
	btn.text = item.get("letter", "?")
	btn.tooltip_text = item.get("label", "")
	btn.custom_minimum_size = Vector2(BTN_DIAM, BTN_DIAM)
	btn.size               = Vector2(BTN_DIAM, BTN_DIAM)

	var r = int(BTN_DIAM / 2)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.10, 0.12, 0.16, 0.92)
	s.border_color = Color(0.40, 0.80, 0.40, 1.0)
	s.set_border_width_all(2)
	s.corner_radius_top_left     = r
	s.corner_radius_top_right    = r
	s.corner_radius_bottom_left  = r
	s.corner_radius_bottom_right = r
	btn.add_theme_stylebox_override("normal", s)

	var sh = s.duplicate()
	sh.bg_color = Color(0.20, 0.50, 0.20, 0.95)
	btn.add_theme_stylebox_override("hover",   sh)
	btn.add_theme_stylebox_override("pressed", sh)
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_on_action.bind(item.get("id", "")))
	return btn

func _on_action(action_id: String) -> void:
	action_selected.emit(action_id)
	visible = false
