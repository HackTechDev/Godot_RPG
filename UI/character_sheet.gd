extends CanvasLayer

const _BASE = "Main/CenterContainer/PanelContainer/MarginContainer/VBoxContainer"
const _COL  = _BASE + "/ContentRow/StatsColumn"
const _VP   = _BASE + "/ContentRow/PreviewPanel/PreviewCenter/CharPreview/PreviewViewport"

@onready var label_health    = get_node(_COL + "/LabelHealth")
@onready var label_attack    = get_node(_COL + "/LabelAttack")
@onready var label_defense   = get_node(_COL + "/LabelDefense")
@onready var label_computers = get_node(_COL + "/LabelComputers")
@onready var label_robots    = get_node(_COL + "/LabelRobots")
@onready var label_scene     = get_node(_COL + "/LabelScene")
@onready var label_inventory = get_node(_COL + "/LabelInventory")

@onready var preview_panel   = get_node(_BASE + "/ContentRow/PreviewPanel")
@onready var _spr_body       = get_node(_VP + "/SpriteBody")
@onready var _spr_legs       = get_node(_VP + "/SpriteLegs")
@onready var _spr_feet       = get_node(_VP + "/SpriteFeet")
@onready var _spr_shoulders  = get_node(_VP + "/SpriteShoulders")
@onready var _spr_torso      = get_node(_VP + "/SpriteTorso")
@onready var _spr_arms       = get_node(_VP + "/SpriteArms")
@onready var _spr_bracers    = get_node(_VP + "/SpriteBracers")
@onready var _spr_gloves     = get_node(_VP + "/SpriteGloves")
@onready var _spr_head       = get_node(_VP + "/SpriteHead")
@onready var _spr_face       = get_node(_VP + "/SpriteFace")
@onready var _spr_hair       = get_node(_VP + "/SpriteHair")
@onready var _spr_headwear   = get_node(_VP + "/SpriteHeadwear")

const _APP_FILES: Dictionary = {
	"body_light":     "res://Sprites/Player/items/010 body_color__light_.png",
	"bangs_black":    "res://Sprites/Player/items/120 bangs__black_.png",
	"armet_iron":     "res://Sprites/Player/items/130 armet__iron_.png",
	"xeon_steel":     "res://Sprites/Player/items/130 xeon_helmet__steel_.png",
	"armour_steel":   "res://Sprites/Player/items/060 armour__steel_.png",
	"armour_iron":    "res://Sprites/Player/items/060 armour__iron_.png",
	"bracers_steel":  "res://Sprites/Player/items/070 bracers__steel_.png",
	"gloves_black":   "res://Sprites/Player/items/070 gloves__black_.png",
	"gloves_brown":   "res://Sprites/Player/items/070 gloves__brown_.png",
	"leather_forest": "res://Sprites/Player/items/060 leather__forest_.png",
	"plate_silver":   "res://Sprites/Player/items/060 plate__silver_.png",
	"armour_ceramic": "res://Sprites/Player/items/020 armour__ceramic_.png",
	"boots_black":    "res://Sprites/Player/items/025 basic_boots__black_.png",
	"boots_charcoal": "res://Sprites/Player/items/025 basic_boots__charcoal_.png",
}
const _HEAD_FILE = "res://Sprites/Player/items/100 human_male__light_.png"
const _FACE_FILE = "res://Sprites/Player/items/101 neutral__light_.png"

func refresh():
	label_health.text    = "Santé : "       + str(Player_data.player_health)
	label_attack.text    = "Attaque : "     + str(Player_data.player_attack)
	label_defense.text   = "Défense : "     + str(Player_data.player_defense)
	label_computers.text = "Ordinateurs : " + str(Player_data.computer)
	label_robots.text    = "Robots : "      + str(Player_data.robot)
	label_scene.text     = "Zone : "        + Player_data.player_previous_scene

	if Player_data.inventory.is_empty():
		label_inventory.text = "(vide)"
	else:
		var lines = []
		for item in Player_data.inventory:
			lines.append("- " + item["label"])
		label_inventory.text = "\n".join(lines)

	_refresh_preview()

func _refresh_preview():
	if Player_data.appearance_body == "":
		preview_panel.visible = false
		return
	preview_panel.visible = true
	_load(_spr_body,    Player_data.appearance_body)
	_load(_spr_legs,    Player_data.appearance_legs)
	_load(_spr_feet,    Player_data.appearance_feet)
	_none(_spr_shoulders)
	_load(_spr_torso,   Player_data.appearance_torso)
	var arms = Player_data.appearance_arms
	if arms in ["armour_steel", "armour_iron"]:
		_load(_spr_arms,    arms)
		_none(_spr_bracers)
	elif arms == "bracers_steel":
		_none(_spr_arms)
		_load(_spr_bracers, "bracers_steel")
	else:
		_none(_spr_arms)
		_none(_spr_bracers)
	_load(_spr_gloves,  Player_data.appearance_hands)
	_file(_spr_head,    _HEAD_FILE)
	_file(_spr_face,    _FACE_FILE)
	_load(_spr_hair,    Player_data.appearance_hair)
	_load(_spr_headwear, Player_data.appearance_headwear)

func _load(spr: Sprite2D, key: String):
	if key == "":
		spr.visible = false
		return
	var path = _APP_FILES.get(key, "")
	if path == "":
		spr.visible = false
		return
	spr.texture  = load(path)
	spr.hframes  = 13
	spr.vframes  = 54
	spr.frame    = 130
	spr.position = Vector2(32, 32)
	spr.visible  = true

func _file(spr: Sprite2D, path: String):
	spr.texture  = load(path)
	spr.hframes  = 13
	spr.vframes  = 54
	spr.frame    = 130
	spr.position = Vector2(32, 32)
	spr.visible  = true

func _none(spr: Sprite2D):
	spr.visible = false

func _on_button_close_pressed():
	visible = false
