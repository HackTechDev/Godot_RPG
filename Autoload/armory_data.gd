extends Node

var weapons: Array = []
var armors:  Array = []
var gadgets: Array = []
var clothes: Array = []

func _ready() -> void:
	weapons = _load_json("res://Armory/weapons.json")
	armors  = _load_json("res://Armory/protections.json")
	gadgets = _load_json("res://Armory/equipments.json")
	clothes = _load_json("res://Armory/clothes.json")

func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("ArmoryData: fichier introuvable : " + path)
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Array else []
