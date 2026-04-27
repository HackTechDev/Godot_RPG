extends CanvasLayer

# ── Dimensions & apparence ────────────────────────────────────────────────────
const MINIMAP_W := 200
const MINIMAP_H := 100
const PADDING   := 6
const TITLE_H   := 16
const REVEAL_R  := 5   # rayon de révélation (en cellules logiques)

const COL_BG         := Color(0.05, 0.06, 0.08, 0.88)
const COL_BORDER     := Color(0.25, 0.60, 0.25, 0.90)
const COL_FLOOR_FOG  := Color(0.12, 0.14, 0.16, 1.0)   # non découvert
const COL_FLOOR_VIS  := Color(0.48, 0.52, 0.58, 1.0)   # découvert
const COL_PLAYER     := Color(0.95, 0.25, 0.25, 1.0)   # point joueur
const COL_TITLE      := Color(0.60, 0.90, 0.60, 1.0)

# ── Nœud de dessin interne ─────────────────────────────────────────────────────
class DrawCtrl extends Control:
	var mm  # référence au MinimapLayer parent
	func _draw() -> void:
		if mm != null:
			mm._do_draw(self)

# ── État de la carte ──────────────────────────────────────────────────────────
var _floor_cells    : Dictionary = {}   # Vector2i → true
var _map_scale      : int  = 128        # px monde par cellule logique
var _bounding_rect  : Rect2i = Rect2i(0, 0, 200, 100)
var _cell_px        : float  = 1.0     # minimap px par cellule logique
var _int_cell_px    : int    = 1

var _player_map     : Vector2i = Vector2i.ZERO
var _prev_player_map: Vector2i = Vector2i(-9999, -9999)

var _map_image  : Image = null
var _map_texture: ImageTexture = null
var _tex_dirty  : bool = false

var _draw_ctrl  : Control = null

# ── Initialisation ────────────────────────────────────────────────────────────
func _ready() -> void:
	layer   = 5
	visible = Player_data.minimap_enabled
	_build_ui()
	EventBus.level_map_ready.connect(_on_level_map_ready)

func _build_ui() -> void:
	var total_w := MINIMAP_W + PADDING * 2
	var total_h := MINIMAP_H + PADDING * 2 + TITLE_H + 4

	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	bg.offset_left   = -(total_w + 8)
	bg.offset_right  = -8
	bg.offset_bottom = -8
	bg.offset_top    = -(total_h + 8)

	var sbox := StyleBoxFlat.new()
	sbox.bg_color                   = COL_BG
	sbox.border_color               = COL_BORDER
	sbox.set_border_width_all(2)
	sbox.corner_radius_top_left     = 4
	sbox.corner_radius_top_right    = 4
	sbox.corner_radius_bottom_right = 4
	sbox.corner_radius_bottom_left  = 4
	bg.add_theme_stylebox_override("panel", sbox)
	add_child(bg)

	var title := Label.new()
	title.text = "— CARTE —"
	title.position = Vector2(PADDING, PADDING)
	title.size     = Vector2(MINIMAP_W, TITLE_H)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", COL_TITLE)
	title.add_theme_constant_override("outline_size", 1)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	bg.add_child(title)

	var dc := DrawCtrl.new()
	dc.mm           = self
	dc.position     = Vector2(PADDING, PADDING + TITLE_H + 4)
	dc.size         = Vector2(MINIMAP_W, MINIMAP_H)
	dc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(dc)
	_draw_ctrl = dc

# ── Activation / désactivation ────────────────────────────────────────────────
func toggle() -> void:
	Player_data.minimap_enabled = not Player_data.minimap_enabled
	visible = Player_data.minimap_enabled
	if visible and _draw_ctrl != null:
		_draw_ctrl.queue_redraw()

# ── Réception de la carte du niveau ───────────────────────────────────────────
func _on_level_map_ready(floor_cells: Array, map_scale: int) -> void:
	_floor_cells.clear()
	Player_data.minimap_visited.clear()
	_map_scale   = map_scale
	_map_image   = null
	_map_texture = null
	_prev_player_map = Vector2i(-9999, -9999)

	if floor_cells.is_empty():
		return

	# Bounding rect
	var min_x := 999999; var min_y := 999999
	var max_x := -999999; var max_y := -999999
	for c: Vector2i in floor_cells:
		_floor_cells[c] = true
		if c.x < min_x: min_x = c.x
		if c.y < min_y: min_y = c.y
		if c.x > max_x: max_x = c.x
		if c.y > max_y: max_y = c.y

	_bounding_rect = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	_cell_px = minf(
		float(MINIMAP_W) / float(max(1, _bounding_rect.size.x)),
		float(MINIMAP_H) / float(max(1, _bounding_rect.size.y))
	)
	_cell_px     = maxf(1.0, _cell_px)
	_int_cell_px = max(1, int(_cell_px))

	# Image de base : toutes les cellules sol en brouillard
	_map_image = Image.create(MINIMAP_W, MINIMAP_H, false, Image.FORMAT_RGBA8)
	_map_image.fill(Color(0.0, 0.0, 0.0, 1.0))
	var ox := float(_bounding_rect.position.x)
	var oy := float(_bounding_rect.position.y)
	for c: Vector2i in _floor_cells:
		_paint_cell(c, ox, oy, COL_FLOOR_FOG)

	_map_texture = ImageTexture.create_from_image(_map_image)
	if _draw_ctrl != null:
		_draw_ctrl.queue_redraw()

# ── Boucle principale ─────────────────────────────────────────────────────────
func _process(_dt: float) -> void:
	if not visible or _map_texture == null:
		return

	var mx := int(Player_data.player_pos_x / float(_map_scale))
	var my := int(Player_data.player_pos_y / float(_map_scale))
	_player_map = Vector2i(mx, my)

	# Révéler les cellules autour du joueur
	var ox := float(_bounding_rect.position.x)
	var oy := float(_bounding_rect.position.y)
	for dy: int in range(-REVEAL_R, REVEAL_R + 1):
		for dx: int in range(-REVEAL_R, REVEAL_R + 1):
			var cell := Vector2i(mx + dx, my + dy)
			if _floor_cells.has(cell) and not Player_data.minimap_visited.has(cell):
				Player_data.minimap_visited[cell] = true
				_paint_cell(cell, ox, oy, COL_FLOOR_VIS)
				_tex_dirty = true

	if _tex_dirty:
		_map_texture.update(_map_image)
		_tex_dirty = false

	if _player_map != _prev_player_map:
		_prev_player_map = _player_map
		if _draw_ctrl != null:
			_draw_ctrl.queue_redraw()

# ── Dessin ────────────────────────────────────────────────────────────────────
func _do_draw(ctrl: Control) -> void:
	if _map_texture == null:
		ctrl.draw_rect(Rect2(Vector2.ZERO, ctrl.size), Color(0.0, 0.0, 0.0, 1.0))
		return

	ctrl.draw_texture(_map_texture, Vector2.ZERO)

	# Point du joueur
	var ox := float(_bounding_rect.position.x)
	var oy := float(_bounding_rect.position.y)
	var px := (float(_player_map.x) - ox) * _cell_px
	var py := (float(_player_map.y) - oy) * _cell_px
	var dot := maxf(3.0, _cell_px * 2.0)
	ctrl.draw_rect(Rect2(px - dot * 0.5, py - dot * 0.5, dot, dot), COL_PLAYER)

# ── Aide interne : peindre une cellule dans l'image ───────────────────────────
func _paint_cell(cell: Vector2i, ox: float, oy: float, col: Color) -> void:
	var sx := int((float(cell.x) - ox) * _cell_px)
	var sy := int((float(cell.y) - oy) * _cell_px)
	for dy: int in _int_cell_px:
		for dx: int in _int_cell_px:
			var px := sx + dx
			var py := sy + dy
			if px >= 0 and px < MINIMAP_W and py >= 0 and py < MINIMAP_H:
				_map_image.set_pixel(px, py, col)
