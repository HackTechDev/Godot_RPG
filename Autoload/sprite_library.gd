extends Node
## SpriteLibrary — chargement automatique des sprite sheets depuis les archives LPC.
##
## Scanne res://Sprites/Player/ pour les fichiers *.zip au démarrage.
## Chaque archive doit contenir :
##   character.json  (exporté par le générateur LPC)
##   items/*.png     (sprite sheets individuels)
##
## Le character.json détermine automatiquement quel sprite va dans quelle couche.
## Les items de toutes les archives sont fusionnés en un catalogue unique.

const _ARCHIVE_DIR = "res://Sprites/Player/"

const _HFRAMES      = 13
const _VFRAMES      = 54
const _PREVIEW_FRAME = 130

# Mapping : clé de sélection JSON (LPC) → { slot, layer }
#   slot  = nom du slot de création de personnage (appearance_*, get_slot_options)
#   layer = nom de la couche Sprite2D à appliquer (get_item_layer)
# Clés absentes (ex: "shoulders") → ignorées silencieusement.
const _SELECTION_TO_SLOT: Dictionary = {
	"body":       {"slot": "body",     "layer": "body"},
	"armour":     {"slot": "torso",    "layer": "torso"},
	"legs":       {"slot": "legs",     "layer": "legs"},
	"shoes":      {"slot": "feet",     "layer": "feet"},
	"hair":       {"slot": "hair",     "layer": "hair"},
	"hat":        {"slot": "headwear", "layer": "headwear"},
	"arms":       {"slot": "arms",     "layer": "arms"},
	"bracers":    {"slot": "arms",     "layer": "bracers"},  # slot partagé avec arms
	"gloves":     {"slot": "hands",    "layer": "hands"},
	"head":       {"slot": "_head",    "layer": "_head"},    # couche fixe
	"expression": {"slot": "_face",    "layer": "_face"},    # couche fixe
}

# Slots qui acceptent l'option "aucun" (tous sauf body et les couches fixes)
const _OPTIONAL_SLOTS = ["hair", "headwear", "arms", "hands", "torso", "legs", "feet"]

# item_key → { texture: ImageTexture, slot: String, layer: String, label: String }
var _items: Dictionary = {}
# slot → Array[{ key: String, label: String }]
var _slots: Dictionary = {}
# "_head" | "_face" → ImageTexture
var _fixed: Dictionary = {}


func _ready() -> void:
	_scan_archives()
	_add_none_options()


# ---------------------------------------------------------------------------
# Chargement des archives
# ---------------------------------------------------------------------------

func _scan_archives() -> void:
	var dir := DirAccess.open(_ARCHIVE_DIR)
	if dir == null:
		push_error("SpriteLibrary: dossier introuvable : " + _ARCHIVE_DIR)
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.to_lower().ends_with(".zip"):
			_load_zip(_ARCHIVE_DIR + fname)
		fname = dir.get_next()
	dir.list_dir_end()


func _load_zip(path: String) -> void:
	var zip := ZIPReader.new()
	if zip.open(path) != OK:
		push_error("SpriteLibrary: impossible d'ouvrir : " + path)
		return

	var files := zip.get_files()

	if not "character.json" in files:
		push_warning("SpriteLibrary: pas de character.json dans : " + path)
		zip.close()
		return

	var json := JSON.new()
	if json.parse(zip.read_file("character.json").get_string_from_utf8()) != OK:
		push_error("SpriteLibrary: JSON invalide dans : " + path)
		zip.close()
		return

	var data:       Dictionary = json.data
	var selections: Dictionary = data.get("selections", {})
	var layers:     Array      = data.get("layers",     [])

	# Reverse map : itemId → clé de sélection (ex: "arms_armour" → "arms")
	var itemid_to_selkey: Dictionary = {}
	for sel_key in selections:
		var iid: String = selections[sel_key].get("itemId", "")
		if iid != "":
			itemid_to_selkey[iid] = sel_key

	# Index des PNGs disponibles dans l'archive
	var png_files: Array = []
	for f in files:
		if f.begins_with("items/") and f.to_lower().ends_with(".png"):
			png_files.append(f)

	# Traiter chaque couche LPC
	for layer in layers:
		var item_id: String = layer.get("itemId", "")
		var z_pos:   int    = layer.get("zPos",   -1)
		var variant: String = layer.get("variant", "")
		var recolors        = layer.get("recolors", null)

		# Qualificatif = variant en priorité, sinon première valeur de recolors
		var qualifier: String = variant
		if qualifier == "" and recolors is Dictionary and not recolors.is_empty():
			qualifier = recolors.values()[0]

		var sel_key: String = itemid_to_selkey.get(item_id, "")
		if sel_key == "" or not _SELECTION_TO_SLOT.has(sel_key):
			continue

		var mapping: Dictionary = _SELECTION_TO_SLOT[sel_key]
		var slot:    String     = mapping["slot"]
		var lyr:     String     = mapping["layer"]

		var png_path: String = _find_png(png_files, z_pos, qualifier)
		if png_path == "":
			push_warning("SpriteLibrary: PNG introuvable — zPos=%d qualifier='%s' (%s)" \
					% [z_pos, qualifier, path])
			continue

		var tex := _load_texture_from_zip(zip, png_path)
		if tex == null:
			continue

		# Couches fixes (head, face) : stockage séparé
		if lyr in ["_head", "_face"]:
			_fixed[lyr] = tex
			continue

		var key:   String = _filename_to_key(png_path.get_file())
		var label: String = selections[sel_key].get("name", key)

		# Enregistrer l'item (les doublons entre archives sont ignorés)
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

	zip.close()


func _add_none_options() -> void:
	for slot in _OPTIONAL_SLOTS:
		if not _slots.has(slot):
			_slots[slot] = []
		_slots[slot].insert(0, {"key": "", "label": "—"})


# ---------------------------------------------------------------------------
# Utilitaires internes
# ---------------------------------------------------------------------------

## Trouve le PNG dans l'archive dont le préfixe correspond à zPos
## et dont le nom contient le qualifier (variant / recolor).
func _find_png(png_files: Array, z_pos: int, qualifier: String) -> String:
	var prefix := "%03d" % z_pos
	var candidates: Array = []
	for f in png_files:
		if f.get_file().begins_with(prefix):
			candidates.append(f)
	if candidates.size() == 1:
		return candidates[0]
	# Désambiguïser par qualifier
	for f in candidates:
		if qualifier != "" and f.to_lower().contains(qualifier.to_lower()):
			return f
	return candidates[0] if not candidates.is_empty() else ""


## Charge une texture PNG directement depuis les octets de l'archive.
func _load_texture_from_zip(zip: ZIPReader, path: String) -> ImageTexture:
	var bytes := zip.read_file(path)
	if bytes.is_empty():
		return null
	var img := Image.new()
	if img.load_png_from_buffer(bytes) != OK:
		push_warning("SpriteLibrary: PNG corrompu : " + path)
		return null
	return ImageTexture.create_from_image(img)


## Dérive une clé stable depuis le nom de fichier LPC.
## Ex : "010 body_color__light_.png" → "body_color_light"
##      "070 bracers__steel_.png"    → "bracers_steel"
func _filename_to_key(filename: String) -> String:
	var name := filename.get_basename()
	# Supprimer le préfixe numérique "NNN "
	var sp := name.find(" ")
	if sp >= 0 and sp <= 4:
		name = name.substr(sp + 1)
	# Normaliser : __ → _, supprimer le _ final
	name = name.replace("__", "_")
	while name.ends_with("_"):
		name = name.left(name.length() - 1)
	return name


# ---------------------------------------------------------------------------
# API publique — métadonnées
# ---------------------------------------------------------------------------

## Retourne les options d'un slot sous la forme Array[{key, label}].
## Le slot "" (aucun) est inclus en premier pour les slots optionnels.
func get_slot_options(slot: String) -> Array:
	return _slots.get(slot, [])

## Retourne la couche Sprite2D cible pour une clé d'item.
## Valeurs : "body", "torso", "legs", "feet", "hair", "headwear",
##           "arms", "bracers", "hands"  (ou "" si clé inconnue)
func get_item_layer(key: String) -> String:
	return _items.get(key, {}).get("layer", "")

func get_texture(key: String) -> Texture2D:
	return _items.get(key, {}).get("texture", null)

func get_head_texture() -> Texture2D:
	return _fixed.get("_head", null)

func get_face_texture() -> Texture2D:
	return _fixed.get("_face", null)


# ---------------------------------------------------------------------------
# API publique — application sur Sprite2D (mode joueur, frame via AnimationTree)
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
# API publique — application sur Sprite2D (mode prévisualisation, frame fixe)
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
