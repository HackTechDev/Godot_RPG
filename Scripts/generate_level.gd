## Générateur de niveau — EditorScript
## Lancer depuis Godot : File › Run Script  (ou Ctrl+Shift+X)
##
## Convention du script Python generate_level.py :
##   '#' = sol (intérieur de pièce + couloir)  → tuile sol (layer_0)
##   'S' = point de départ du joueur            → tuile sol + spawn
##   '>' = sortie de niveau                     → tuile sol
##   ' ' = vide / mur extérieur                → aucune tuile
##
## Les murs Godot (layer_1, avec collision) sont auto-générés :
## toute cellule ' ' adjacente (8 directions) à une cellule sol
## devient une tuile mur.
##
## Échelle : 1 caractère ASCII = 1 tuile = 200 pixels dans Godot.
@tool
extends EditorScript

# ── Constantes ────────────────────────────────────────────────────────────────
const TILE_PX      := 200
const TEMPLATE     := "res://Scenes/Levels/level_4/level_4.tscn"
const LEVELS_BASE  := "res://Scenes/Levels"
const MISSIONS_RES := "res://missions.json"

const GROUND_SRC   := 524288   # atlas col=8 → tuile de sol
const WALL_SRC     := 327680   # atlas col=5 → tuile de mur
const TILE_GROUND  := 26
const TILE_WALL    := 31

# ── Point d'entrée ─────────────────────────────────────────────────────────────
func _run() -> void:
	generate_from_file(10, "res://Scripts/level_001.txt")

# ── Configuration par niveau ──────────────────────────────────────────────────
const LEVEL_CFGS := {
	5:  {"uid_scn":"dnvqh8m3p7r2t","uid_gd":"cxjf9k6m1w4q8","node_id":1361413525,"spawn":Vector2i(12,25)},
	6:  {"uid_scn":"bm5rw2j9f8n3k","uid_gd":"cp7t4x1h5n8q2","node_id":1361413526,"spawn":Vector2i(6,23)},
	7:  {"uid_scn":"dq3f7w9r2m1p5","uid_gd":"bk8n2x5j4r7w1","node_id":1361413527,"spawn":Vector2i(27,8)},
	8:  {"uid_scn":"cm6t1p8r4j9n2","uid_gd":"dw4x7f3m9q5k1","node_id":1361413528,"spawn":Vector2i(21,12)},
	9:  {"uid_scn":"bp9k5r2m7j4n6","uid_gd":"cj3q8w1f5x7n4","node_id":1361413529,"spawn":Vector2i(34,18)},
	10: {"uid_scn":"dt7m4n9r6j2p8","uid_gd":"bq5j1w8k3n7r2","node_id":1361413530,"spawn":Vector2i(6,12)},
}

# ── Génération depuis un fichier texte (sortie de generate_level.py) ──────────
func generate_from_file(n: int, txt_path: String) -> void:
	if not LEVEL_CFGS.has(n):
		push_error("Pas de configuration pour le niveau %d" % n); return

	var text := FileAccess.get_file_as_string(txt_path)
	if text.is_empty():
		push_error("Impossible de lire : " + txt_path); return

	var lines := text.split("\n")

	# ── Étape 1 : identifier les cellules sol ────────────────────────────────
	# '#' = sol, 'S' = spawn (sol), '>' = sortie (sol), ' ' = vide
	var floor_map: Dictionary = {}   # Vector2i → String (le caractère)
	var sp := Vector2i(-1, -1)

	for y in lines.size():
		var row: String = lines[y]
		for x in row.length():
			var c: String = row[x]
			match c:
				"#", "S", ">":
					floor_map[Vector2i(x, y)] = c
					if c == "S" and sp.x == -1:
						sp = Vector2i(x, y)

	if floor_map.is_empty():
		push_error("Aucune cellule sol trouvée dans : " + txt_path); return

	var gnd: Array[Vector2i] = []
	for pos: Vector2i in floor_map:
		gnd.append(pos)

	# ── Étape 2 : générer les murs autour des cellules sol ───────────────────
	# Chaque cellule ' ' adjacente (8 directions) à une cellule sol → mur Godot
	var wall_set: Dictionary = {}
	for pos: Vector2i in gnd:
		for dy: int in range(-1, 2):
			for dx: int in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var nb := Vector2i(pos.x + dx, pos.y + dy)
				if not floor_map.has(nb):
					wall_set[nb] = true

	var wll: Array[Vector2i] = []
	for pos: Vector2i in wall_set:
		wll.append(pos)

	var cfg := LEVEL_CFGS[n] as Dictionary
	if sp.x == -1:
		sp = cfg["spawn"] as Vector2i
		print("  Aucun 'S' trouvé — spawn config utilisé : (%d, %d)" % [sp.x, sp.y])

	_write_level(n, cfg, gnd, wll, sp)

# ── Génération depuis les fonctions de design intégrées (niveaux 5–9) ─────────
func generate(n: int) -> void:
	if not LEVEL_CFGS.has(n):
		push_error("Pas de configuration pour le niveau %d" % n); return

	var cfg  := LEVEL_CFGS[n] as Dictionary
	var sp   := cfg["spawn"] as Vector2i
	var grid := _design(n)
	if grid.is_empty(): return

	var gnd: Array[Vector2i] = []
	var wll: Array[Vector2i] = []
	for y in grid.size():
		var row: Array = grid[y]
		for x in row.size():
			var c: String = row[x] as String
			match c:
				".", "S":
					gnd.append(Vector2i(x, y))
					if c == "S":
						sp = Vector2i(x, y)
				"#":
					wll.append(Vector2i(x, y))

	if not (sp in gnd):
		gnd.append(sp)
		print("  spawn corrigé : (%d,%d) ajouté au sol" % [sp.x, sp.y])

	_write_level(n, cfg, gnd, wll, sp)

# ── Écriture effective du niveau ───────────────────────────────────────────────
func _write_level(n: int, cfg: Dictionary, gnd: Array[Vector2i], wll: Array[Vector2i], sp: Vector2i) -> void:
	var tmpl := FileAccess.get_file_as_string(TEMPLATE)
	if tmpl.is_empty():
		push_error("Impossible de lire le template : " + TEMPLATE); return

	var uid_scn := cfg["uid_scn"] as String
	var uid_gd  := cfg["uid_gd"]  as String
	var nid     := cfg["node_id"] as int
	var ct      := tmpl

	ct = ct.replace(
		'uid="uid://b46h3lkah31mp"',
		'uid="uid://%s"' % uid_scn)
	ct = ct.replace(
		'uid="uid://b5a8bmiga2obh" path="res://Scenes/Levels/level_4/level_4.gd"',
		'uid="uid://%s" path="res://Scenes/Levels/level_%d/level_%d.gd"' % [uid_gd, n, n])
	ct = ct.replace(
		'[node name="level_4" type="Node2D" unique_id=1361413524]',
		'[node name="level_%d" type="Node2D" unique_id=%d]' % [n, nid])
	# Scale 12.5× sur le nœud TileMap : tuile atlas 16 px → 200 px monde.
	# Le tile_size (16 px) et les polygones de collision (±8 px) restent
	# inchangés ; le transform du nœud les agrandit automatiquement.
	ct = ct.replace(
		'[node name="ground" type="TileMap" parent="." unique_id=1201899630]\ny_sort_enabled',
		'[node name="ground" type="TileMap" parent="." unique_id=1201899630]\ntransform = Transform2D(12.5, 0, 0, 12.5, 0, 0)\ny_sort_enabled')

	ct = _replace_layer(ct, "layer_0", _make_arr(gnd, GROUND_SRC, TILE_GROUND))
	ct = _replace_layer(ct, "layer_1", _make_arr(wll, WALL_SRC,   TILE_WALL))

	var dir := "%s/level_%d" % [LEVELS_BASE, n]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))

	_write(dir + "/level_%d.tscn" % n, ct)
	_write_json(dir + "/objects.json",           _get_objects(n, sp))
	_write_json(dir + "/enemies.json",            [])
	_write_json(dir + "/npcs.json",               [])
	_write_json(dir + "/level_connections.json",  {"connections": []})

	var gd_path := dir + "/level_%d.gd" % n
	if not FileAccess.file_exists(gd_path):
		_write(gd_path,
			'extends "res://Scenes/Levels/base_level.gd"\n\nfunc _ready():\n\tsuper._ready()\n')
	_write(dir + "/level_%d.gd.uid" % n, "uid://" + uid_gd)

	_update_mission_spawn(n, sp.x * TILE_PX, sp.y * TILE_PX)

	print("level_%d généré ✓  sol:%d  murs:%d  spawn:(%d,%d)px" % [
		n, gnd.size(), wll.size(), sp.x * TILE_PX, sp.y * TILE_PX])

# ── Encodage PackedInt32Array ──────────────────────────────────────────────────
func _encode_cell(x: int, y: int) -> int:
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

# ── Helpers de grille ASCII (designs intégrés niveaux 5–9) ────────────────────
func _mkgrid(w: int, h: int) -> Array:
	var g: Array = []
	for _y in h:
		var row: Array = []
		row.resize(w)
		row.fill(".")
		g.append(row)
	return g

func _bwall(g: Array) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for x in W:
		g[0][x]     = "#"
		g[H - 1][x] = "#"
	for y in H:
		g[y][0]     = "#"
		g[y][W - 1] = "#"

func _hw(g: Array, y: int, x0: int, x1: int) -> void:
	for x in range(x0, x1 + 1):
		g[y][x] = "#"

func _vw(g: Array, x: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		g[y][x] = "#"

func _dr(g: Array, y: int, x: int) -> void:
	g[y][x] = "."

func _room(g: Array, y0: int, x0: int, y1: int, x1: int) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			g[y][x] = "#" if (y == y0 or y == y1 or x == x0 or x == x1) else "."

func _clr(g: Array, y0: int, x0: int, y1: int, x1: int) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if y > 0 and y < H - 1 and x > 0 and x < W - 1:
				g[y][x] = "."

func _blk(g: Array, y: int, x: int) -> void:
	var H := g.size()
	var W := (g[0] as Array).size()
	for dy in 2:
		for dx in 2:
			var ny := y + dy; var nx := x + dx
			if ny > 0 and ny < H - 1 and nx > 0 and nx < W - 1:
				g[ny][nx] = "#"

# ── Designs de niveaux intégrés (5–9) ────────────────────────────────────────
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
		for seg in row_data[1]: _hw(g, y, seg[0], seg[1])
		for gx  in row_data[2]: _dr(g, y, gx)
	var vert := [
		[8,  [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[16, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[24, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[32, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
		[40, [[1,5],[7,11],[13,17],[19,23],[25,29],[31,34]], [6,12,18,24,30]],
	]
	for col_data in vert:
		var x: int = col_data[0]
		for seg in col_data[1]: _vw(g, x, seg[0], seg[1])
		for gy  in col_data[2]: _dr(g, gy, x)
	_clr(g, 23, 10, 27, 14)
	return g

func _d6() -> Array:
	var W := 46; var H := 34
	var g := _mkgrid(W, H)
	for y in H:
		for x in W:
			if not (18 <= y and y <= 26): g[y][x] = "#"
	for y in range(18, 27):
		g[y][0] = "#"; g[y][W - 1] = "#"
	for bx in [7, 17, 27, 38]:
		for y in range(10, 18): g[y][bx] = "."
		g[10][bx - 1] = "."; g[10][bx + 1] = "."; g[9][bx] = "."
	for bx in [12, 22, 34]:
		for y in range(26, 32): g[y][bx] = "."
		g[31][bx] = "."; g[32][bx] = "."
	for cx in [15, 30]:
		_vw(g, cx, 18, 26)
		_dr(g, 21, cx); _dr(g, 22, cx); _dr(g, 23, cx)
	_clr(g, 20, 3, 26, 12)
	return g

func _d7() -> Array:
	var g := _mkgrid(56, 42)
	_bwall(g)
	_room(g, 2, 2, 39, 53)
	_dr(g, 2, 27); _dr(g, 2, 28); _dr(g, 39, 27); _dr(g, 39, 28)
	_dr(g, 20, 2); _dr(g, 21, 2); _dr(g, 20, 53); _dr(g, 21, 53)
	_hw(g, 20, 3, 52)
	for x in [13, 14, 27, 28, 41, 42]: _dr(g, 20, x)
	_vw(g, 27, 3, 38)
	_dr(g, 10, 27); _dr(g, 11, 27); _dr(g, 29, 27); _dr(g, 30, 27)
	_room(g,  3,  3, 11, 14); _dr(g, 11,  8); _dr(g, 11,  9)
	_room(g,  3, 16, 11, 25); _dr(g, 11, 20); _dr(g, 11, 21)
	_room(g,  3, 29, 11, 40); _dr(g, 11, 34); _dr(g, 11, 35)
	_room(g,  3, 42, 11, 52); _dr(g, 11, 47); _dr(g, 11, 48)
	_room(g, 22,  3, 38, 25)
	_dr(g, 29, 14); _dr(g, 30, 14); _dr(g, 22, 14); _dr(g, 23, 14)
	_room(g, 22, 29, 38, 52)
	_dr(g, 29, 40); _dr(g, 30, 40); _dr(g, 22, 40); _dr(g, 23, 40)
	for x in range(25, 31):
		g[39][x] = "."; g[40][x] = "."
	_clr(g, 3, 15, 11, 26)
	return g

func _d8() -> Array:
	var W := 46
	var g := _mkgrid(W, 30)
	_bwall(g)
	_hw(g, 8, 1, W - 2)
	for x in [10, 11, 22, 23, 34, 35]: _dr(g, 8, x)
	_hw(g, 16, 1, W - 2)
	for x in [10, 11, 22, 23, 34, 35]: _dr(g, 16, x)
	_hw(g, 22, 1, W - 2)
	for x in [10, 11, 22, 23]: _dr(g, 22, x)
	_vw(g, 10, 1, 28); _dr(g, 12, 10); _dr(g, 13, 10); _dr(g, 20, 10)
	_vw(g, 23, 1, 28); _dr(g, 12, 23); _dr(g, 13, 23); _dr(g, 20, 23)
	_vw(g, 36, 1, 28); _dr(g, 12, 36); _dr(g, 13, 36)
	_room(g, 17, 12, 21, 22); _dr(g, 17, 16); _dr(g, 17, 17)
	_room(g, 17, 24, 21, 35); _dr(g, 17, 29); _dr(g, 17, 30)
	_room(g,  2, 11,  7, 22); _dr(g,  7, 16); _dr(g,  7, 17)
	_clr(g, 9, 19, 15, 22)
	return g

func _d9() -> Array:
	var g := _mkgrid(56, 36)
	_bwall(g)
	_hw(g, 17, 14, 22); _hw(g, 17, 26, 34); _hw(g, 17, 38, 46)
	_dr(g, 17, 23); _dr(g, 17, 24); _dr(g, 17, 35); _dr(g, 17, 36)
	_hw(g,  7,  4, 11); _hw(g,  7, 18, 24); _hw(g,  7, 36, 42); _hw(g,  7, 48, 53)
	_hw(g, 27,  8, 14); _hw(g, 27, 22, 30); _hw(g, 27, 40, 48)
	for ox in [6, 12, 20, 28, 44, 50]: _vw(g, ox, 10, 13)
	for ox in [9, 16, 24, 36, 47]:    _vw(g, ox, 22, 25)
	for entry in [[4,4],[4,26],[4,48],[12,15],[12,38],[22,8],[22,30],[22,48],[30,18],[30,42]]:
		_blk(g, entry[0], entry[1])
	_hw(g,  3,  2, 53); _dr(g,  3, 10); _dr(g,  3, 26); _dr(g,  3, 42)
	_hw(g, 32,  2, 53); _dr(g, 32, 10); _dr(g, 32, 26); _dr(g, 32, 42)
	_clr(g, 15, 32, 21, 38)
	return g

func _design(n: int) -> Array:
	match n:
		5: return _d5()
		6: return _d6()
		7: return _d7()
		8: return _d8()
		9: return _d9()
	push_error("Aucun design pour le niveau %d" % n)
	return []

# ── Objets collectables ───────────────────────────────────────────────────────
# Pour generate_from_file, sp est la tuile 'S' lue dans le fichier.
# Les objets sont placés à +offset depuis le spawn (en pixels).
func _get_objects(n: int, sp: Vector2i = Vector2i(0, 0)) -> Array:
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
				{"type":"computer","x":(sp.x + 5)*k, "y":(sp.y + 0)*k},
				{"type":"computer","x":(sp.x + 0)*k, "y":(sp.y + 5)*k},
				{"type":"robot",   "x":(sp.x + 8)*k, "y":(sp.y + 0)*k},
				{"type":"robot",   "x":(sp.x + 0)*k, "y":(sp.y + 8)*k}]
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
	var arr: Array = JSON.parse_string(text) as Array
	if arr == null: return
	for m: Dictionary in arr:
		var sc: String = m.get("scene", "")
		if sc.ends_with("level_%d/level_%d.tscn" % [level_n, level_n]):
			m["spawn"] = {"x": px, "y": py}
	var fa := FileAccess.open(abs, FileAccess.WRITE)
	fa.store_string(JSON.stringify(arr, "\t"))
	fa.close()
