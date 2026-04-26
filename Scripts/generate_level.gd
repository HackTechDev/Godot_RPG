## Générateur de niveau — EditorScript
## Lancer depuis Godot : File › Run Script  (ou Ctrl+Shift+X)
##
## Correspondance des caractères ASCII :
##   '#'  → mur   (avec collision)
##   '.'  → sol   (pas de collision)
##   'S'  → point de départ du joueur (traité comme '.')
##
## Échelle : 1 caractère ASCII = 1 tuile = 200 pixels dans Godot.
## Le spawn dans missions.json est mis à jour automatiquement (tuile × 200).
@tool
extends EditorScript

# ── Constantes ────────────────────────────────────────────────────────────────
const TILE_PX      := 200     # 1 tuile ASCII = 200 px dans l'espace monde
const TEMPLATE     := "res://Scenes/Levels/level_4/level_4.tscn"
const LEVELS_BASE  := "res://Scenes/Levels"
const MISSIONS_RES := "res://missions.json"

# Encodage PackedInt32Array hérité du tileset existant (tileset_scifi.png 16 px)
const GROUND_SRC   := 524288  # atlas col=8, row=0  → tuile de sol
const WALL_SRC     := 327680  # atlas col=5, row=0  → tuile de mur
const TILE_GROUND  := 26
const TILE_WALL    := 31

# ── Point d'entrée ─────────────────────────────────────────────────────────────
func _run() -> void:
	generate(10)          # ← changer le numéro pour un autre niveau

# ── Configuration par niveau ──────────────────────────────────────────────────
# uid_scn  : UID de la scène  (doit être unique dans le projet)
# uid_gd   : UID du script .gd attaché
# node_id  : unique_id du nœud racine
# spawn    : coordonnée de la tuile de départ (sera × TILE_PX)
const LEVEL_CFGS := {
	5:  {"uid_scn":"dnvqh8m3p7r2t","uid_gd":"cxjf9k6m1w4q8","node_id":1361413525,"spawn":Vector2i(12,25)},
	6:  {"uid_scn":"bm5rw2j9f8n3k","uid_gd":"cp7t4x1h5n8q2","node_id":1361413526,"spawn":Vector2i(6,23)},
	7:  {"uid_scn":"dq3f7w9r2m1p5","uid_gd":"bk8n2x5j4r7w1","node_id":1361413527,"spawn":Vector2i(27,8)},
	8:  {"uid_scn":"cm6t1p8r4j9n2","uid_gd":"dw4x7f3m9q5k1","node_id":1361413528,"spawn":Vector2i(21,12)},
	9:  {"uid_scn":"bp9k5r2m7j4n6","uid_gd":"cj3q8w1f5x7n4","node_id":1361413529,"spawn":Vector2i(34,18)},
	10: {"uid_scn":"dt7m4n9r6j2p8","uid_gd":"bq5j1w8k3n7r2","node_id":1361413530,"spawn":Vector2i(6,12)},
}

# ── Génération principale ──────────────────────────────────────────────────────
func generate(n: int) -> void:
	if not LEVEL_CFGS.has(n):
		push_error("Pas de configuration pour le niveau %d" % n); return

	var cfg     := LEVEL_CFGS[n] as Dictionary
	var sp      := cfg["spawn"] as Vector2i
	var grid    := _design(n)
	if grid.is_empty(): return

	# Sépare les cellules sol / mur
	var gnd: Array[Vector2i] = []
	var wll: Array[Vector2i] = []
	for y in grid.size():
		var row: Array = grid[y]
		for x in row.size():
			match row[x]:
				".", "S": gnd.append(Vector2i(x, y))
				"#":       wll.append(Vector2i(x, y))

	# Assure que le spawn est sur du sol
	if not (sp in gnd):
		gnd.append(sp)
		print("  spawn corrigé : ajout de (%d,%d) dans le sol" % [sp.x, sp.y])

	# Lit le template (level_4.tscn) et substitue les données
	var tmpl := FileAccess.get_file_as_string(TEMPLATE)
	if tmpl.is_empty():
		push_error("Impossible de lire le template : " + TEMPLATE); return

	var uid_scn := cfg["uid_scn"] as String
	var uid_gd  := cfg["uid_gd"]  as String
	var nid     := cfg["node_id"] as int

	var ct := tmpl

	# --- UIDs et nom du nœud racine ---
	ct = ct.replace(
		'uid="uid://b46h3lkah31mp"',
		'uid="uid://%s"' % uid_scn)
	ct = ct.replace(
		'uid="uid://b5a8bmiga2obh" path="res://Scenes/Levels/level_4/level_4.gd"',
		'uid="uid://%s" path="res://Scenes/Levels/level_%d/level_%d.gd"' % [uid_gd, n, n])
	ct = ct.replace(
		'[node name="level_4" type="Node2D" unique_id=1361413524]',
		'[node name="level_%d" type="Node2D" unique_id=%d]' % [n, nid])

	# --- Taille de tuile : 200 px au lieu de 16 px (défaut) ---
	ct = ct.replace(
		'physics_layer_0/collision_layer = 1',
		'tile_size = Vector2i(200, 200)\nphysics_layer_0/collision_layer = 1')

	# --- Polygones de collision : ±8 → ±100 (demi-tuile de 200 px) ---
	ct = ct.replace(
		'PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)',
		'PackedVector2Array(-100, -100, 100, -100, 100, 100, -100, 100)')

	# --- Données de tuiles des deux calques ---
	ct = _replace_layer(ct, "layer_0", _make_arr(gnd, GROUND_SRC, TILE_GROUND))
	ct = _replace_layer(ct, "layer_1", _make_arr(wll, WALL_SRC,   TILE_WALL))

	# Écriture des fichiers
	var dir := "%s/level_%d" % [LEVELS_BASE, n]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))

	_write(dir + "/level_%d.tscn" % n, ct)
	_write_json(dir + "/objects.json",           _get_objects(n))
	_write_json(dir + "/enemies.json",            [])
	_write_json(dir + "/npcs.json",               [])
	_write_json(dir + "/level_connections.json",  {"connections": []})

	var gd_path := dir + "/level_%d.gd" % n
	if not FileAccess.file_exists(gd_path):
		_write(gd_path,
			'extends "res://Scenes/Levels/base_level.gd"\n\nfunc _ready():\n\tsuper._ready()\n')

	_write(dir + "/level_%d.gd.uid" % n, "uid://" + uid_gd)

	# Mise à jour du spawn dans missions.json (tuile × TILE_PX)
	_update_mission_spawn(n, sp.x * TILE_PX, sp.y * TILE_PX)

	print("level_%d généré ✓  (sol:%d  murs:%d  spawn:(%d,%d) px)" % [
		n, gnd.size(), wll.size(), sp.x * TILE_PX, sp.y * TILE_PX])

# ── Encodage PackedInt32Array ──────────────────────────────────────────────────
func _encode_cell(x: int, y: int) -> int:
	# Coordonnées de tuile (entiers signés 16 bits) → clé int32 signée
	var xi := x & 0xFFFF
	var yi := y & 0xFFFF
	var k  := (yi << 16) | xi
	if k >= 0x80000000:
		k -= 0x100000000
	return k

func _make_arr(cells: Array, src: int, tid: int) -> String:
	if cells.is_empty():
		return "PackedInt32Array()"
	var nums: PackedStringArray = []
	for c: Vector2i in cells:
		nums.append(str(_encode_cell(c.x, c.y)))
		nums.append(str(src))
		nums.append(str(tid))
	return "PackedInt32Array(%s)" % ", ".join(nums)

func _replace_layer(ct: String, layer: String, arr: String) -> String:
	var rx := RegEx.new()
	rx.compile(layer + r"/tile_data = PackedInt32Array\([^)]*\)")
	var m := rx.search(ct)
	if m:
		ct = ct.left(m.get_start()) + layer + "/tile_data = " + arr + ct.substr(m.get_end())
	return ct

# ── Helpers de grille ASCII (conversion exacte du Python) ─────────────────────

# Crée une grille W×H remplie de '.'
func _mkgrid(w: int, h: int) -> Array:
	var g: Array = []
	for _y in h:
		var row: Array = []
		row.resize(w)
		row.fill(".")
		g.append(row)
	return g

# Mur de bordure extérieure
func _bwall(g: Array) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for x in W:
		g[0][x]     = "#"
		g[H - 1][x] = "#"
	for y in H:
		g[y][0]     = "#"
		g[y][W - 1] = "#"

# Mur horizontal (inclusive)
func _hw(g: Array, y: int, x0: int, x1: int) -> void:
	for x in range(x0, x1 + 1):
		g[y][x] = "#"

# Mur vertical (inclusive)
func _vw(g: Array, x: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		g[y][x] = "#"

# Porte (efface une cellule)
func _dr(g: Array, y: int, x: int) -> void:
	g[y][x] = "."

# Pièce rectangulaire (bordure '#', intérieur '.')
func _room(g: Array, y0: int, x0: int, y1: int, x1: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			g[y][x] = "#" if (y == y0 or y == y1 or x == x0 or x == x1) else "."

# Efface une zone rectangulaire (force '.' sauf bordure extérieure)
func _clr(g: Array, y0: int, x0: int, y1: int, x1: int) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if y > 0 and y < H - 1 and x > 0 and x < W - 1:
				g[y][x] = "."

# Pilier 2×2
func _blk(g: Array, y: int, x: int) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for dy in 2:
		for dx in 2:
			var ny := y + dy
			var nx := x + dx
			if ny > 0 and ny < H - 1 and nx > 0 and nx < W - 1:
				g[ny][nx] = "#"

# ── Designs de niveaux ────────────────────────────────────────────────────────

# Labyrinthe nocturne — 50×36  spawn(12,25)
func _d5() -> Array:
	var g := _mkgrid(50, 36)
	_bwall(g)
	var horiz := [
		[6,  [[2,12],[16,26],[30,42],[46,48]], [13,14,27,28,43,44]],
		[12, [[2,8],[12,22],[26,34],[38,48]],  [9,10,23,24,35,36]],
		[18, [[2,16],[20,28],[32,40],[44,48]], [17,18,29,30,41,42]],
		[24, [[2,10],[14,24],[28,36],[40,48]], [11,12,25,26,37,38]],
		[30, [[2,14],[18,28],[32,42],[46,48]], [15,16,29,30,43,44]],
	]
	for row_data in horiz:
		var y: int = row_data[0]
		for seg in row_data[1]:
			_hw(g, y, seg[0], seg[1])
		for gx in row_data[2]:
			_dr(g, y, gx)
	var vert := [
		[8,  [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[16, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[24, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[32, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[40, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
	]
	for col_data in vert:
		var x: int = col_data[0]
		for seg in col_data[1]:
			_vw(g, x, seg[0], seg[1])
		for gy in col_data[2]:
			_dr(g, gy, x)
	_clr(g, 23, 10, 27, 14)
	return g

# Couloir de transit — 46×34  spawn(6,23)
func _d6() -> Array:
	var W := 46; var H := 34
	var g := _mkgrid(W, H)
	for y in H:
		for x in W:
			if not (18 <= y and y <= 26):
				g[y][x] = "#"
	for y in range(18, 27):
		g[y][0]     = "#"
		g[y][W - 1] = "#"
	for bx in [7, 17, 27, 38]:
		for y in range(10, 18):
			g[y][bx] = "."
		g[10][bx - 1] = "."
		g[10][bx + 1] = "."
		g[9][bx]      = "."
	for bx in [12, 22, 34]:
		for y in range(26, 32):
			g[y][bx] = "."
		g[31][bx] = "."
		g[32][bx] = "."
	for cx in [15, 30]:
		_vw(g, cx, 18, 26)
		_dr(g, 21, cx)
		_dr(g, 22, cx)
		_dr(g, 23, cx)
	_clr(g, 20, 3, 26, 12)
	return g

# Bâtiment multi-salles — 56×42  spawn(27,8)
func _d7() -> Array:
	var g := _mkgrid(56, 42)
	_bwall(g)
	_room(g,  2,  2, 39, 53)
	_dr(g,  2, 27); _dr(g,  2, 28)
	_dr(g, 39, 27); _dr(g, 39, 28)
	_dr(g, 20,  2); _dr(g, 21,  2)
	_dr(g, 20, 53); _dr(g, 21, 53)
	_hw(g, 20, 3, 52)
	for x in [13, 14, 27, 28, 41, 42]:
		_dr(g, 20, x)
	_vw(g, 27, 3, 38)
	_dr(g, 10, 27); _dr(g, 11, 27)
	_dr(g, 29, 27); _dr(g, 30, 27)
	_room(g,  3,  3, 11, 14); _dr(g, 11,  8); _dr(g, 11,  9)
	_room(g,  3, 16, 11, 25); _dr(g, 11, 20); _dr(g, 11, 21)
	_room(g,  3, 29, 11, 40); _dr(g, 11, 34); _dr(g, 11, 35)
	_room(g,  3, 42, 11, 52); _dr(g, 11, 47); _dr(g, 11, 48)
	_room(g, 22,  3, 38, 25)
	_dr(g, 29, 14); _dr(g, 30, 14); _dr(g, 22, 14); _dr(g, 23, 14)
	_room(g, 22, 29, 38, 52)
	_dr(g, 29, 40); _dr(g, 30, 40); _dr(g, 22, 40); _dr(g, 23, 40)
	for x in range(25, 31):
		g[39][x] = "."
		g[40][x] = "."
	_clr(g, 3, 15, 11, 26)
	return g

# Installation classifiée — 46×30  spawn(21,12)
func _d8() -> Array:
	var W := 46
	var g := _mkgrid(W, 30)
	_bwall(g)
	_hw(g, 8, 1, W - 2)
	for x in [10, 11, 22, 23, 34, 35]:
		_dr(g, 8, x)
	_hw(g, 16, 1, W - 2)
	for x in [10, 11, 22, 23, 34, 35]:
		_dr(g, 16, x)
	_hw(g, 22, 1, W - 2)
	for x in [10, 11, 22, 23]:
		_dr(g, 22, x)
	_vw(g, 10, 1, 28); _dr(g, 12, 10); _dr(g, 13, 10); _dr(g, 20, 10)
	_vw(g, 23, 1, 28); _dr(g, 12, 23); _dr(g, 13, 23); _dr(g, 20, 23)
	_vw(g, 36, 1, 28); _dr(g, 12, 36); _dr(g, 13, 36)
	_room(g, 17, 12, 21, 22); _dr(g, 17, 16); _dr(g, 17, 17)
	_room(g, 17, 24, 21, 35); _dr(g, 17, 29); _dr(g, 17, 30)
	_room(g,  2, 11,  7, 22); _dr(g,  7, 16); _dr(g,  7, 17)
	_clr(g, 9, 19, 15, 22)
	return g

# Zone ouverte avec couvertures — 56×36  spawn(34,18)
func _d9() -> Array:
	var g := _mkgrid(56, 36)
	_bwall(g)
	_hw(g, 17, 14, 22); _hw(g, 17, 26, 34); _hw(g, 17, 38, 46)
	_dr(g, 17, 23); _dr(g, 17, 24); _dr(g, 17, 35); _dr(g, 17, 36)
	_hw(g,  7,  4, 11); _hw(g,  7, 18, 24); _hw(g,  7, 36, 42); _hw(g,  7, 48, 53)
	_hw(g, 27,  8, 14); _hw(g, 27, 22, 30); _hw(g, 27, 40, 48)
	for ox in [6, 12, 20, 28, 44, 50]:
		_vw(g, ox, 10, 13)
	for ox in [9, 16, 24, 36, 47]:
		_vw(g, ox, 22, 25)
	for entry in [[4,4],[4,26],[4,48],[12,15],[12,38],[22,8],[22,30],[22,48],[30,18],[30,42]]:
		_blk(g, entry[0], entry[1])
	_hw(g,  3,  2, 53); _dr(g,  3, 10); _dr(g,  3, 26); _dr(g,  3, 42)
	_hw(g, 32,  2, 53); _dr(g, 32, 10); _dr(g, 32, 26); _dr(g, 32, 42)
	_clr(g, 15, 32, 21, 38)
	return g

# Forteresse Assiégée — 58×46  spawn(6,12)
func _d10() -> Array:
	var W := 58; var H := 46
	var g := _mkgrid(W, H)
	_bwall(g)
	# Double mur intérieur — anneau horizontal (row 3 et row 42)
	for x in range(1, W - 1):
		g[3][x]         = "#"
		g[H - 4][x]     = "#"
	# Double mur intérieur — anneau vertical (col 3 et col 54)
	for y in range(1, H - 1):
		g[y][3]         = "#"
		g[y][W - 4]     = "#"
	# Ouvertures latérales dans l'anneau (col 3 et col 54)
	for y in [12, 13, 31, 32]:
		g[y][3]         = "."
		g[y][W - 4]     = "."
	# Ouvertures haut/bas dans l'anneau (row 3 et row 42)
	for x in [22, 23, 36, 37]:
		g[3][x]         = "."
		g[H - 4][x]     = "."
	# Tours de coin
	_room(g, 1,       1,       7,       7)
	_room(g, 1,       W - 8,   7,       W - 2)
	_room(g, H - 8,   1,       H - 2,   7)
	_room(g, H - 8,   W - 8,   H - 2,   W - 2)
	# QG central avec deux portes nord et sud
	_room(g, 17, 20, 29, 38)
	_dr(g, 17, 28); _dr(g, 17, 29)
	_dr(g, 29, 28); _dr(g, 29, 29)
	# Murs horizontaux nord (row 11)
	_hw(g, 11,  4, 19); _dr(g, 11, 11); _dr(g, 11, 12)
	_hw(g, 11, 39, 53); _dr(g, 11, 46); _dr(g, 11, 47)
	# Murs horizontaux sud (row 34)
	_hw(g, 34,  4, 19); _dr(g, 34, 11); _dr(g, 34, 12)
	_hw(g, 34, 39, 53); _dr(g, 34, 46)
	# Séparations verticales nord (col 20 et 38, rows 4–16)
	_vw(g, 20,  4, 16); _dr(g, 10, 20); _dr(g, 11, 20)
	_vw(g, 38,  4, 16); _dr(g, 10, 38); _dr(g, 11, 38)
	# Séparations verticales sud (col 20 et 38, rows 30–42)
	_vw(g, 20, 30, 42); _dr(g, 36, 20)
	_vw(g, 38, 30, 42); _dr(g, 36, 38)
	# Zone de spawn libre (nord-ouest, rows 9–16, cols 4–12)
	_clr(g, 9, 4, 16, 12)
	# Marque le spawn
	g[12][6] = "S"
	return g

func _design(n: int) -> Array:
	match n:
		5:  return _d5()
		6:  return _d6()
		7:  return _d7()
		8:  return _d8()
		9:  return _d9()
		10: return _d10()
	push_error("Aucun design pour le niveau %d" % n)
	return []

# ── Objets collectables par niveau ────────────────────────────────────────────
# Les coordonnées x/y sont en pixels (tuile × TILE_PX)
func _get_objects(n: int) -> Array:
	var k := TILE_PX
	match n:
		5:  return [
				{"type":"computer","x": 4*k,"y": 4*k},
				{"type":"computer","x":36*k,"y":30*k},
				{"type":"robot",   "x":22*k,"y": 9*k},
				{"type":"robot",   "x":10*k,"y":26*k}]
		6:  return [
				{"type":"computer","x": 4*k,"y":21*k},
				{"type":"computer","x":32*k,"y":22*k},
				{"type":"robot",   "x":15*k,"y":21*k},
				{"type":"robot",   "x":23*k,"y":21*k}]
		7:  return [
				{"type":"computer","x": 5*k,"y": 5*k},
				{"type":"computer","x":38*k,"y":32*k},
				{"type":"robot",   "x":10*k,"y":28*k},
				{"type":"robot",   "x":34*k,"y": 6*k}]
		8:  return [
				{"type":"computer","x": 5*k,"y":20*k},
				{"type":"computer","x":32*k,"y":21*k},
				{"type":"robot",   "x":10*k,"y": 5*k},
				{"type":"robot",   "x":26*k,"y":25*k}]
		9:  return [
				{"type":"computer","x": 4*k,"y": 4*k},
				{"type":"computer","x":38*k,"y":28*k},
				{"type":"robot",   "x":14*k,"y":18*k},
				{"type":"robot",   "x":26*k,"y": 8*k}]
		10: return [
				{"type":"computer","x": 6*k,"y": 6*k},
				{"type":"computer","x":44*k,"y":38*k},
				{"type":"robot",   "x":28*k,"y":13*k},
				{"type":"robot",   "x":14*k,"y":28*k}]
	return []

# ── I/O ───────────────────────────────────────────────────────────────────────
func _write(res_path: String, content: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	var fa  := FileAccess.open(abs, FileAccess.WRITE)
	if fa == null:
		push_error("Écriture impossible : " + abs); return
	fa.store_string(content)
	fa.close()

func _write_json(res_path: String, data: Variant) -> void:
	_write(res_path, JSON.stringify(data, "\t"))

func _update_mission_spawn(level_n: int, px: int, py: int) -> void:
	var abs  := ProjectSettings.globalize_path(MISSIONS_RES)
	var text := FileAccess.get_file_as_string(abs)
	var arr  := JSON.parse_string(text)
	if arr == null: return
	for m: Dictionary in arr:
		var sc: String = m.get("scene", "")
		if sc.ends_with("level_%d/level_%d.tscn" % [level_n, level_n]):
			m["spawn"] = {"x": px, "y": py}
	var fa := FileAccess.open(abs, FileAccess.WRITE)
	fa.store_string(JSON.stringify(arr, "\t"))
	fa.close()
