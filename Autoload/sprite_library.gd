extends Node
## SpriteLibrary — catalogue des sprite sheets LPC, chargé au démarrage.
##
## Toute la configuration est déclarée ici en constantes GDScript.
## Pour ajouter un sprite : 1) ajouter l'entrée dans _ITEMS,
##                           2) ajouter la clé dans le bon slot de _SLOTS.
## Les libellés UI sont déduits automatiquement des clés.

const _BASE_PATH     = "res://Sprites/Player/items/"
const _HFRAMES       = 13
const _VFRAMES       = 54
const _PREVIEW_FRAME = 130
const _HEAD          = "100 human_male__light_.png"
const _FACE          = "101 neutral__light_.png"

# clé → nom de fichier relatif (dans _BASE_PATH)
const _ITEMS: Dictionary = {
	"body_light":     "010 body_color__light_.png",
	"bangs_black":    "120 bangs__black_.png",
	"armet_iron":     "130 armet__iron_.png",
	"xeon_steel":     "130 xeon_helmet__steel_.png",
	"armour_steel":   "060 armour__steel_.png",
	"armour_iron":    "060 armour__iron_.png",
	"bracers_steel":  "070 bracers__steel_.png",
	"gloves_black":   "070 gloves__black_.png",
	"gloves_brown":   "070 gloves__brown_.png",
	"leather_forest": "060 leather__forest_.png",
	"plate_silver":   "060 plate__silver_.png",
	"armour_ceramic": "020 armour__ceramic_.png",
	"boots_black":    "025 basic_boots__black_.png",
	"boots_charcoal": "025 basic_boots__charcoal_.png",
}

# slot → liste ordonnée de clés ("" = aucun)
const _SLOTS: Dictionary = {
	"body":     ["body_light"],
	"hair":     ["", "bangs_black"],
	"headwear": ["", "armet_iron", "xeon_steel"],
	"arms":     ["", "armour_steel", "armour_iron", "bracers_steel"],
	"hands":    ["", "gloves_black", "gloves_brown"],
	"torso":    ["", "leather_forest", "plate_silver"],
	"legs":     ["", "armour_ceramic"],
	"feet":     ["", "boots_black", "boots_charcoal"],
}

# cache chemin absolu → Texture2D
var _textures: Dictionary = {}


func _ready() -> void:
	_cache_texture(_BASE_PATH + _HEAD)
	_cache_texture(_BASE_PATH + _FACE)
	for key in _ITEMS:
		_cache_texture(_BASE_PATH + _ITEMS[key])


func _cache_texture(path: String) -> void:
	if _textures.has(path):
		return
	if ResourceLoader.exists(path):
		_textures[path] = load(path)
	else:
		push_warning("SpriteLibrary: texture introuvable : " + path)


# ---------------------------------------------------------------------------
# API publique — textures
# ---------------------------------------------------------------------------

func get_texture(key: String) -> Texture2D:
	if key == "":
		return null
	var file: String = _ITEMS.get(key, "")
	if file == "":
		push_warning("SpriteLibrary: clé inconnue : " + key)
		return null
	return _textures.get(_BASE_PATH + file, null)

func get_head_texture() -> Texture2D:
	return _textures.get(_BASE_PATH + _HEAD, null)

func get_face_texture() -> Texture2D:
	return _textures.get(_BASE_PATH + _FACE, null)


# ---------------------------------------------------------------------------
# API publique — options de slot
# Retourne Array[{key, label}] ; le libellé est généré depuis la clé.
# ---------------------------------------------------------------------------

func get_slot_options(slot: String) -> Array:
	var result: Array = []
	for key in _SLOTS.get(slot, []):
		result.append({"key": key, "label": _key_to_label(key)})
	return result

func _key_to_label(key: String) -> String:
	if key == "":
		return "—"
	return key.replace("_", " ").capitalize()


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
