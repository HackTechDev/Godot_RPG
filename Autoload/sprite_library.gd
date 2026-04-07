extends Node
## SpriteLibrary — chargement générique des sprite sheets au démarrage.
##
## Lit Data/sprite_sheets.json et précharge toutes les textures en cache.
## Expose des fonctions génériques pour appliquer un sprite à un Sprite2D,
## et pour récupérer les options de chaque slot d'apparence.

const _DATA_PATH = "res://Data/sprite_sheets.json"

var _base_path:     String = ""
var _hframes:       int    = 13
var _vframes:       int    = 54
var _preview_frame: int    = 130
var _head_file:     String = ""
var _face_file:     String = ""

# clé → chemin de fichier relatif (ex: "body_light" → "010 body_color__light_.png")
var _items: Dictionary = {}
# slot → Array[{key, label}]  (ex: "body" → [{key:"body_light", label:"Carnation claire"}])
var _slots: Dictionary = {}
# chemin absolu res:// → Texture2D (cache)
var _textures: Dictionary = {}


func _ready() -> void:
	_load_config()


func _load_config() -> void:
	var file = FileAccess.open(_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("SpriteLibrary: impossible de lire " + _DATA_PATH)
		return

	var json = JSON.new()
	var err  = json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("SpriteLibrary: erreur JSON ligne %d : %s" % [json.get_error_line(), json.get_error_message()])
		return

	var data: Dictionary = json.data.get("sprite_sheets", {})
	_base_path     = data.get("base_path",     "res://Sprites/Player/items/")
	_hframes       = data.get("hframes",       13)
	_vframes       = data.get("vframes",       54)
	_preview_frame = data.get("preview_frame", 130)
	_head_file     = data.get("head",          "")
	_face_file     = data.get("face",          "")
	_items         = data.get("items",         {})
	_slots         = data.get("slots",         {})

	# Préchargement de toutes les textures déclarées
	_cache_texture(_base_path + _head_file)
	_cache_texture(_base_path + _face_file)
	for key in _items:
		if _items[key] != "":
			_cache_texture(_base_path + _items[key])


func _cache_texture(path: String) -> void:
	if path == "" or _textures.has(path):
		return
	if ResourceLoader.exists(path):
		_textures[path] = load(path)
	else:
		push_warning("SpriteLibrary: texture introuvable : " + path)


# ---------------------------------------------------------------------------
# API publique — récupération de textures
# ---------------------------------------------------------------------------

## Retourne la texture associée à une clé d'item (ex: "body_light").
## Retourne null si la clé est vide ou inconnue.
func get_texture(key: String) -> Texture2D:
	if key == "":
		return null
	var file: String = _items.get(key, "")
	if file == "":
		push_warning("SpriteLibrary: clé inconnue : " + key)
		return null
	return _textures.get(_base_path + file, null)

## Retourne la texture de tête de base.
func get_head_texture() -> Texture2D:
	return _textures.get(_base_path + _head_file, null)

## Retourne la texture de visage de base.
func get_face_texture() -> Texture2D:
	return _textures.get(_base_path + _face_file, null)

## Retourne les options d'un slot (ex: "body", "hair", "headwear"…).
## Chaque élément est un Dictionary {key, label}.
func get_slot_options(slot: String) -> Array:
	return _slots.get(slot, [])


# ---------------------------------------------------------------------------
# API publique — application sur Sprite2D (mode joueur, frame géré par AnimationTree)
# ---------------------------------------------------------------------------

## Applique la texture d'un item (par clé) au Sprite2D.
## Cache le sprite si la clé est vide ou inconnue.
func apply_sprite(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.visible = false
		return
	spr.texture = tex
	spr.hframes = _hframes
	spr.vframes = _vframes
	spr.visible = true

## Applique la texture de tête de base au Sprite2D (mode joueur).
func apply_head_sprite(spr: Sprite2D) -> void:
	spr.texture = get_head_texture()
	spr.hframes = _hframes
	spr.vframes = _vframes
	spr.visible = true

## Applique la texture de visage de base au Sprite2D (mode joueur).
func apply_face_sprite(spr: Sprite2D) -> void:
	spr.texture = get_face_texture()
	spr.hframes = _hframes
	spr.vframes = _vframes
	spr.visible = true


# ---------------------------------------------------------------------------
# API publique — application sur Sprite2D (mode prévisualisation, frame fixe)
# ---------------------------------------------------------------------------

## Applique la texture d'un item (par clé) en mode prévisualisation.
## Cache le sprite si la clé est vide ou inconnue.
func apply_preview_sprite(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.texture = null
		return
	spr.texture = tex
	spr.hframes = _hframes
	spr.vframes = _vframes
	spr.frame   = _preview_frame

## Applique la texture de tête de base en mode prévisualisation.
func apply_head_preview(spr: Sprite2D) -> void:
	spr.texture  = get_head_texture()
	spr.hframes  = _hframes
	spr.vframes  = _vframes
	spr.frame    = _preview_frame
	spr.position = Vector2(32, 32)
	spr.visible  = true

## Applique la texture de visage de base en mode prévisualisation.
func apply_face_preview(spr: Sprite2D) -> void:
	spr.texture  = get_face_texture()
	spr.hframes  = _hframes
	spr.vframes  = _vframes
	spr.frame    = _preview_frame
	spr.position = Vector2(32, 32)
	spr.visible  = true

## Applique la texture d'un item en mode prévisualisation avec position centrée.
func apply_preview_sprite_centered(spr: Sprite2D, key: String) -> void:
	var tex := get_texture(key)
	if tex == null:
		spr.texture = null
		return
	spr.texture  = tex
	spr.hframes  = _hframes
	spr.vframes  = _vframes
	spr.frame    = _preview_frame
	spr.position = Vector2(32, 32)
	spr.visible  = true
