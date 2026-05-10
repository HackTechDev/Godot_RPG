extends CanvasLayer

signal action_selected(action_id: String)
signal closed

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
	_animate_open()

func _animate_open() -> void:
	_container.scale    = Vector2(0.05, 0.05)
	_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tw = create_tween().set_parallel(true)
	tw.tween_property(_container, "scale",    Vector2.ONE,       0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_container, "modulate", Color(1, 1, 1, 1), 0.16) \
		.set_trans(Tween.TRANS_LINEAR)

func _close() -> void:
	_container.scale    = Vector2.ONE
	_container.modulate = Color(1, 1, 1, 1)
	visible = false
	closed.emit()

func _build(items: Array) -> void:
	for c in _container.get_children():
		c.queue_free()
	var n = items.size()
	for i in range(n):
		var a      = -PI / 2.0 + 2.0 * PI * i / float(n)
		var off    = Vector2(cos(a), sin(a)) * RADIUS
		var wrapper = _make_item(items[i], a)
		wrapper.position = off - Vector2(BTN_DIAM / 2.0, BTN_DIAM / 2.0)
		_container.add_child(wrapper)

func _make_item(item: Dictionary, angle: float = 0.0) -> Control:
	var is_disabled: bool = item.get("disabled", false)
	var wrapper = Control.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var btn = _make_btn(item)
	wrapper.add_child(btn)

	const LBL_W = 70.0
	const LBL_H = 14.0
	const PAD   = 3.0
	var lbl = Label.new()
	lbl.text = item.get("label", "")
	lbl.size = Vector2(LBL_W, LBL_H)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Position et alignement du label selon la position angulaire du bouton
	var sa := sin(angle)
	var ca := cos(angle)
	if abs(sa) > 0.98:                                   # axe vertical pur (haut / bas)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if sa < 0.0:                                     # bouton du haut → label au-dessus
			lbl.position = Vector2((BTN_DIAM - LBL_W) / 2.0, -LBL_H - PAD)
		else:                                            # bouton du bas → label en-dessous
			lbl.position = Vector2((BTN_DIAM - LBL_W) / 2.0, BTN_DIAM + PAD)
	elif ca > 0.0:                                       # demi-cercle droit → label à droite
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		lbl.position = Vector2(BTN_DIAM + PAD, (BTN_DIAM - LBL_H) / 2.0)
	else:                                                # demi-cercle gauche → label à gauche
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.position = Vector2(-LBL_W - PAD, (BTN_DIAM - LBL_H) / 2.0)
	lbl.add_theme_font_size_override("font_size", 10)
	var lbl_color = Color(0.45, 0.45, 0.45, 0.7) if is_disabled else Color(0.92, 0.92, 0.92, 1.0)
	lbl.add_theme_color_override("font_color", lbl_color)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	wrapper.add_child(lbl)

	return wrapper

func _make_btn(item: Dictionary) -> Button:
	var is_disabled: bool = item.get("disabled", false)
	var btn = Button.new()
	btn.text = item.get("letter", "?")
	btn.tooltip_text = item.get("label", "")
	btn.disabled = is_disabled
	btn.custom_minimum_size = Vector2(BTN_DIAM, BTN_DIAM)
	btn.size               = Vector2(BTN_DIAM, BTN_DIAM)

	var r = int(BTN_DIAM / 2)

	if is_disabled:
		var sd = StyleBoxFlat.new()
		sd.bg_color = Color(0.12, 0.12, 0.12, 0.55)
		sd.border_color = Color(0.30, 0.30, 0.30, 0.50)
		sd.set_border_width_all(2)
		sd.corner_radius_top_left     = r
		sd.corner_radius_top_right    = r
		sd.corner_radius_bottom_left  = r
		sd.corner_radius_bottom_right = r
		btn.add_theme_stylebox_override("disabled", sd)
		btn.add_theme_color_override("font_disabled_color", Color(0.40, 0.40, 0.40, 0.65))
	else:
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
		btn.pressed.connect(_on_action.bind(item.get("id", "")))

	btn.add_theme_font_size_override("font_size", 14)
	return btn

func _on_action(action_id: String) -> void:
	action_selected.emit(action_id)
	_close()
