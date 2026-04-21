extends CanvasLayer

const BAR_W = 420.0
const BAR_H = 5.0

var overlay:        ColorRect
var _panel:         Control
var _progress_fill: ColorRect
var _loading_label: Label

var _loading_path: String = ""
var _progress:     Array  = [0.0]
var _is_loading:   bool   = false
var _dot_timer:    float  = 0.0
var _dot_count:    int    = 0

func _ready() -> void:
	layer        = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	var vp   = get_viewport().get_visible_rect().size
	var cx   = vp.x / 2.0
	var top  = vp.y * 0.42

	# Fond noir
	overlay = ColorRect.new()
	overlay.color        = Color(0, 0, 0, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Panneau de chargement (caché par défaut)
	_panel = Control.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.visible = false
	add_child(_panel)

	# Ligne décorative haute
	var line_top = ColorRect.new()
	line_top.color    = Color(0.82, 0.72, 0.28, 0.45)
	line_top.size     = Vector2(BAR_W, 1.0)
	line_top.position = Vector2(cx - BAR_W / 2.0, top - 18.0)
	_panel.add_child(line_top)

	# Titre
	var title = Label.new()
	title.text = "COMMANDO ZOMBI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color",         Color(0.83, 0.72, 0.28, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.0,  0.0,  0.0,  1.0))
	title.add_theme_constant_override("outline_size", 3)
	title.size     = Vector2(BAR_W, 56.0)
	title.position = Vector2(cx - BAR_W / 2.0, top)
	_panel.add_child(title)

	# Sous-titre
	var sub = Label.new()
	sub.text = "MERCENARY RPG"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.60, 0.53, 0.35, 0.80))
	sub.size     = Vector2(BAR_W, 22.0)
	sub.position = Vector2(cx - BAR_W / 2.0, top + 58.0)
	_panel.add_child(sub)

	# Ligne décorative basse
	var line_bot = ColorRect.new()
	line_bot.color    = Color(0.82, 0.72, 0.28, 0.45)
	line_bot.size     = Vector2(BAR_W, 1.0)
	line_bot.position = Vector2(cx - BAR_W / 2.0, top + 90.0)
	_panel.add_child(line_bot)

	# Fond de la barre de progression
	var bar_bg = ColorRect.new()
	bar_bg.color    = Color(0.10, 0.10, 0.10, 1.0)
	bar_bg.size     = Vector2(BAR_W, BAR_H)
	bar_bg.position = Vector2(cx - BAR_W / 2.0, top + 108.0)
	_panel.add_child(bar_bg)

	# Remplissage de la barre (largeur animée)
	_progress_fill = ColorRect.new()
	_progress_fill.color    = Color(0.28, 0.72, 0.28, 1.0)
	_progress_fill.size     = Vector2(0.0, BAR_H)
	_progress_fill.position = Vector2(cx - BAR_W / 2.0, top + 108.0)
	_panel.add_child(_progress_fill)

	# Texte de chargement
	_loading_label = Label.new()
	_loading_label.text = "CHARGEMENT"
	_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_label.add_theme_font_size_override("font_size", 11)
	_loading_label.add_theme_color_override("font_color", Color(0.42, 0.42, 0.42, 1.0))
	_loading_label.size     = Vector2(BAR_W, 18.0)
	_loading_label.position = Vector2(cx - BAR_W / 2.0, top + 120.0)
	_panel.add_child(_loading_label)

func _process(delta: float) -> void:
	if not _is_loading:
		return

	# Anime les points de suspension
	_dot_timer += delta
	if _dot_timer >= 0.38:
		_dot_timer = 0.0
		_dot_count = (_dot_count + 1) % 4
		_loading_label.text = "CHARGEMENT" + ".".repeat(_dot_count)

	# Interroge le statut du chargement asynchrone
	var status = ResourceLoader.load_threaded_get_status(_loading_path, _progress)
	_progress_fill.size.x = BAR_W * clampf(_progress[0], 0.0, 1.0)

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			_progress_fill.size.x = BAR_W
			_is_loading = false
			_panel.visible = false
			var packed: PackedScene = ResourceLoader.load_threaded_get(_loading_path)
			get_tree().change_scene_to_packed(packed)

		ResourceLoader.THREAD_LOAD_FAILED:
			_is_loading = false
			_panel.visible = false
			# Repli sur le chargement synchrone en cas d'erreur
			get_tree().change_scene_to_file(_loading_path)

func change_scene(path: String) -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw = create_tween()
	tw.tween_property(overlay, "color:a", 1.0, 0.30)
	tw.tween_callback(func(): _start_loading(path))

func _start_loading(path: String) -> void:
	_loading_path    = path
	_progress        = [0.0]
	_dot_count       = 0
	_dot_timer       = 0.0
	_progress_fill.size.x = 0.0
	_loading_label.text   = "CHARGEMENT"
	_panel.visible   = true
	_is_loading      = true
	ResourceLoader.load_threaded_request(path, "PackedScene", true)

func fade_in() -> void:
	overlay.color.a      = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw = create_tween()
	tw.tween_property(overlay, "color:a", 0.0, 0.35)
