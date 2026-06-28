extends Node
## SpriteLibrary — chargement des sprite sheets LPC depuis res://Sprites/Player/.
##
## Lit character.json (catalogue de couches) et sprite_index.json (liste des PNG)
## puis charge les textures avec load() — compatible web et toutes plateformes.
## Les PNG dans items/ sont importés par Godot et inclus automatiquement dans le PCK.

const _BASE_DIR   = "res://Sprites/Player/"
const _ITEMS_DIR  = "res://Sprites/Player/items/"
const _CHAR_JSON  = "res://Sprites/Player/character.json"
const _INDEX_JSON = "res://Sprites/Player/sprite_index.json"

const _HFRAMES       = 13
const _VFRAMES       = 54
const _PREVIEW_FRAME = 130

const _SELECTION_TO_SLOT: Dictionary = {
	"body":       {"slot": "body",     "layer": "body"},
	"armour":     {"slot": "torso",    "layer": "torso"},
	"legs":       {"slot": "legs",     "layer": "legs"},
	"shoes":      {"slot": "feet",     "layer": "feet"},
	"hair":       {"slot": "hair",     "layer": "hair"},
	"hat":        {"slot": "headwear", "layer": "headwear"},
	"arms":       {"slot": "arms",     "layer": "arms"},
	"bracers":    {"slot": "arms",     "layer": "bracers"},
	"gloves":     {"slot": "hands",    "layer": "hands"},
	"head":       {"slot": "_head",    "layer": "_head"},
	"expression": {"slot": "_face",    "layer": "_face"},
}

const _OPTIONAL_SLOTS = ["hair", "headwear", "arms", "hands", "torso", "legs", "feet"]

var _items: Dictionary = {}
var _slots: Dictionary = {}
var _fixed: Dictionary = {}


func _ready() -> void:
	_load_catalogue()
	_add_none_options()


func _load_catalogue() -> void:
	# Lire character.json
	var json_text := _read_text(_CHAR_JSON)
	if json_text == "":
		push_error("SpriteLibrary: character.json introuvable")
		return
	var data = JSON.parse_string(json_text)
	if not data is Dictionary:
		push_error("SpriteLibrary: character.json invalide")
		return

	var selections: Dictionary = data.get("selections", {})
	var layers: Array         = data.get("layers",     [])

	# Reverse map : itemId → clé de sélection
	var itemid_to_selkey: Dictionary = {}
	for sel_key in selections:
		var iid: String = selections[sel_key].get("itemId", "")
		if iid != "":
			itemid_to_selkey[iid] = sel_key

	# Lire sprite_index.json (liste des fichiers PNG dans items/)
	var index_text := _read_text(_INDEX_JSON)
	var png_files: Array = []
	if index_text != "":
		var parsed = JSON.parse_string(index_text)
		if parsed is Array:
			png_files = parsed

	# Traiter chaque couche
	for layer in layers:
		var item_id: String = layer.get("itemId", "")
		var z_pos:   int    = layer.get("zPos",   -1)
		var variant: String = layer.get("variant", "")
		var recolors        = layer.get("recolors", null)

		var qualifier: String = variant
		if qualifier == "" and recolors is Dictionary and not recolors.is_empty():
			qualifier = recolors.values()[0]

		var sel_key: String = itemid_to_selkey.get(item_id, "")
		if sel_key == "" or not _SELECTION_TO_SLOT.has(sel_key):
			continue

		var mapping: Dictionary = _SELECTION_TO_SLOT[sel_key]
		var slot:    String     = mapping["slot"]
		var lyr:     String     = mapping["layer"]

		var png_name: String = _find_png(png_files, z_pos, qualifier)
		if png_name == "":
			push_warning("SpriteLibrary: PNG introuvable — zPos=%d qualifier='%s'" % [z_pos, qualifier])
			continue

		var tex := _load_texture(_ITEMS_DIR + png_name)
		if tex == null:
			continue

		if lyr in ["_head", "_face"]:
			_fixed[lyr] = tex
			continue

		var key:   String = _filename_to_key(png_name)
		var label: String = selections[sel_key].get("name", key)

		if not _items.has(key):
			_items[key] = {"texture": tex, "slot": slot, "layer": lyr, "label": label}

		if not _slots.has(slot):
			_slots[slot] = []
		var already := false
		for entry in _slots[slot]:
			if entry["key"] == key:
				already = true
				break
		if not already:
			_slots[slot].append({"key": key, "label": label})


func _add_none_options() -> void:
	for slot in _OPTIONAL_SLOTS:
		if not _slots.has(slot):
			_slots[slot] = []
		_slots[slot].insert(0, {"key": "", "label": "—"})


# ---------------------------------------------------------------------------
# Utilitaires internes
# ---------------------------------------------------------------------------

func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var text := f.get_as_text()
	f.close()
	return text


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		push_warning("SpriteLibrary: texture introuvable : " + path)
		return null
	return load(path) as Texture2D


func _find_png(png_files: Array, z_pos: int, qualifier: String) -> String:
	var prefix := "%03d" % z_pos
	var candidates: Array = []
	for f in png_files:
		if (f as String).get_file().begins_with(prefix):
			candidates.append(f)
	if candidates.size() == 1:
		return candidates[0]
	for f in candidates:
		if qualifier != "" and (f as String).to_lower().contains(qualifier.to_lower()):
			return f
	return candidates[0] if not candidates.is_empty() else ""


func _filename_to_key(filename: String) -> String:
	var stem := filename.get_basename()
	var sp := stem.find(" ")
	if sp >= 0 and sp <= 4:
		stem = stem.substr(sp + 1)
	stem = stem.replace("__", "_")
	while stem.ends_with("_"):
		stem = stem.left(stem.length() - 1)
	return stem


# ---------------------------------------------------------------------------
# API publique — métadonnées
# ---------------------------------------------------------------------------

func get_slot_options(slot: String) -> Array:
	return _slots.get(slot, [])

func get_item_layer(key: String) -> String:
	return _items.get(key, {}).get("layer", "")

func get_texture(key: String) -> Texture2D:
	return _items.get(key, {}).get("texture", null)

func get_head_texture() -> Texture2D:
	return _fixed.get("_head", null)

func get_face_texture() -> Texture2D:
	return _fixed.get("_face", null)


# ---------------------------------------------------------------------------
# API publique — application sur Sprite2D (mode joueur)
# ---------------------------------------------------------------------------

func apply_sprite(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.visible = false
		return
	spr.texture = tex
	spr.hframes = _HFRAMES
	spr.vframes = _VFRAMES
	spr.visible = true

func apply_head_sprite(spr: Sprite2D) -> void:
	spr.texture = get_head_texture()
	spr.hframes = _HFRAMES
	spr.vframes = _VFRAMES
	spr.visible = true

func apply_face_sprite(spr: Sprite2D) -> void:
	spr.texture = get_face_texture()
	spr.hframes = _HFRAMES
	spr.vframes = _VFRAMES
	spr.visible = true


# ---------------------------------------------------------------------------
# API publique — application sur Sprite2D (mode prévisualisation)
# ---------------------------------------------------------------------------

func apply_preview_sprite(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.texture = null
		return
	spr.texture = tex
	spr.hframes = _HFRAMES
	spr.vframes = _VFRAMES
	spr.frame   = _PREVIEW_FRAME

func apply_preview_sprite_centered(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.texture = null
		return
	spr.texture  = tex
	spr.hframes  = _HFRAMES
	spr.vframes  = _VFRAMES
	spr.frame    = _PREVIEW_FRAME
	spr.position = Vector2(32, 32)
	spr.visible  = true

func apply_head_preview(spr: Sprite2D) -> void:
	spr.texture  = get_head_texture()
	spr.hframes  = _HFRAMES
	spr.vframes  = _VFRAMES
	spr.frame    = _PREVIEW_FRAME
	spr.position = Vector2(32, 32)
	spr.visible  = true

func apply_face_preview(spr: Sprite2D) -> void:
	spr.texture  = get_face_texture()
	spr.hframes  = _HFRAMES
	spr.vframes  = _VFRAMES
	spr.frame    = _PREVIEW_FRAME
	spr.position = Vector2(32, 32)
	spr.visible  = true
