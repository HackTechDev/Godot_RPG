extends Node

class_name PartyData

const MAX_SLOTS := 4
const SAVE_PATH := "user://party.json"

# Each slot: { "slug": String, "data": Dictionary }
# "data" is a snapshot of Player_data fields + "pos_x"/"pos_y"
static var slots: Array[Dictionary] = []
static var active_slot: int = 0

# Runtime node references — cleared on each level load
static var _nodes: Array = []   # Array[Node2D or null]

# ── Node management ─────────────────────────────────────────────────────────

static func clear_nodes() -> void:
	_nodes.clear()

static func register_node(idx: int, node: Node2D) -> void:
	while _nodes.size() <= idx:
		_nodes.append(null)
	_nodes[idx] = node

static func get_node_at(idx: int) -> Node2D:
	if idx >= 0 and idx < _nodes.size():
		return _nodes[idx] as Node2D
	return null

static func active_node() -> Node2D:
	return get_node_at(active_slot)

# ── Slot helpers ─────────────────────────────────────────────────────────────

static func slot_count() -> int:
	return slots.size()

static func has_slot(slug: String) -> bool:
	for s: Dictionary in slots:
		if s.get("slug", "") == slug:
			return true
	return false

static func add_slot(slug: String, data: Dictionary = {}) -> void:
	if slots.size() >= MAX_SLOTS or has_slot(slug):
		return
	slots.append({"slug": slug, "data": data.duplicate()})

static func remove_slot_by_slug(slug: String) -> void:
	for i in range(slots.size() - 1, -1, -1):
		if slots[i].get("slug", "") == slug:
			slots.remove_at(i)
			if active_slot >= slots.size():
				active_slot = max(0, slots.size() - 1)
			break

static func setup_solo(slug: String) -> void:
	slots.clear()
	_nodes.clear()
	active_slot = 0
	slots.append({"slug": slug, "data": snapshot_player_data()})

# ── Player_data snapshot / restore ──────────────────────────────────────────

static func snapshot_player_data() -> Dictionary:
	return {
		"player_health":          Player_data.player_health,
		"player_health_base":     Player_data.player_health_base,
		"player_movement":        Player_data.player_movement,
		"player_movement_base":   Player_data.player_movement_base,
		"player_attack":          Player_data.player_attack,
		"player_defense":         Player_data.player_defense,
		"player_stamina":         Player_data.player_stamina,
		"player_stealth":         Player_data.player_stealth,
		"player_speed":           Player_data.player_speed,
		"player_precision":       Player_data.player_precision,
		"player_strength":        Player_data.player_strength,
		"player_intelligence":    Player_data.player_intelligence,
		"player_weight_capacity": Player_data.player_weight_capacity,
		"player_credit":          Player_data.player_credit,
		"player_nickname":        Player_data.player_nickname,
		"player_biography":       Player_data.player_biography,
		"player_rank":            Player_data.player_rank,
		"player_specialization":  Player_data.player_specialization,
		"appearance_body":        Player_data.appearance_body,
		"appearance_hair":        Player_data.appearance_hair,
		"appearance_headwear":    Player_data.appearance_headwear,
		"appearance_arms":        Player_data.appearance_arms,
		"appearance_hands":       Player_data.appearance_hands,
		"appearance_torso":       Player_data.appearance_torso,
		"appearance_legs":        Player_data.appearance_legs,
		"appearance_feet":        Player_data.appearance_feet,
		"player_facing":          Player_data.player_facing,
	}

static func restore_to_player_data(d: Dictionary) -> void:
	if d.is_empty():
		return
	Player_data.player_health          = d.get("player_health", 4)
	Player_data.player_health_base     = d.get("player_health_base", 4)
	Player_data.player_movement        = d.get("player_movement", 50)
	Player_data.player_movement_base   = d.get("player_movement_base", 50)
	Player_data.player_attack          = d.get("player_attack", 0)
	Player_data.player_defense         = d.get("player_defense", 0)
	Player_data.player_stamina         = d.get("player_stamina", 0)
	Player_data.player_stealth         = d.get("player_stealth", 0)
	Player_data.player_speed           = d.get("player_speed", 0)
	Player_data.player_precision       = d.get("player_precision", 0)
	Player_data.player_strength        = d.get("player_strength", 0)
	Player_data.player_intelligence    = d.get("player_intelligence", 0)
	Player_data.player_weight_capacity = d.get("player_weight_capacity", 0)
	Player_data.player_credit          = d.get("player_credit", 0)
	Player_data.player_nickname        = d.get("player_nickname", "")
	Player_data.player_biography       = d.get("player_biography", "")
	Player_data.player_rank            = d.get("player_rank", "")
	Player_data.player_specialization  = d.get("player_specialization", "")
	Player_data.appearance_body        = d.get("appearance_body", "")
	Player_data.appearance_hair        = d.get("appearance_hair", "")
	Player_data.appearance_headwear    = d.get("appearance_headwear", "")
	Player_data.appearance_arms        = d.get("appearance_arms", "")
	Player_data.appearance_hands       = d.get("appearance_hands", "")
	Player_data.appearance_torso       = d.get("appearance_torso", "")
	Player_data.appearance_legs        = d.get("appearance_legs", "")
	Player_data.appearance_feet        = d.get("appearance_feet", "")
	Player_data.player_facing          = d.get("player_facing", 2)

# ── Persistence ─────────────────────────────────────────────────────────────

static func save_party() -> void:
	var out: Dictionary = {"active_slot": active_slot, "slots": []}
	for s: Dictionary in slots:
		out["slots"].append({"slug": s.get("slug", ""), "data": s.get("data", {})})
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(out))
		file.close()

# Capture l'état courant de tous les membres de l'équipe puis écrit party.json.
# À appeler à chaque point de sauvegarde (transition, quit, auto-save).
static func save_full_party() -> void:
	# Slot actif : snapshot complet depuis Player_data + position courante
	if active_slot < slots.size():
		var snap := snapshot_player_data()
		snap["pos_x"] = Player_data.player_pos_x
		snap["pos_y"] = Player_data.player_pos_y
		slots[active_slot]["data"] = snap
	# Slots inactifs : mise à jour de la position depuis le nœud de scène
	for i in range(slots.size()):
		if i == active_slot:
			continue
		var node := get_node_at(i)
		if is_instance_valid(node):
			var d: Dictionary = slots[i].get("data", {})
			d["pos_x"] = node.global_position.x
			d["pos_y"] = node.global_position.y
			slots[i]["data"] = d
	save_party()

static func load_party() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		return false
	var new_slots: Array[Dictionary] = []
	for s in data.get("slots", []):
		var slug: String = s.get("slug", "")
		if slug != "":
			new_slots.append({"slug": slug, "data": s.get("data", {})})
	if new_slots.is_empty():
		return false
	slots = new_slots
	active_slot = data.get("active_slot", 0)
	if active_slot >= slots.size():
		active_slot = 0
	return true
