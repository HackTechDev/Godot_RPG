extends Node

@warning_ignore("unused_signal") signal build_computer(direction)
@warning_ignore("unused_signal") signal item_collected(text: String)
@warning_ignore("unused_signal") signal player_mounted_mecha(mecha: Node)
@warning_ignore("unused_signal") signal player_dismounted_mecha()

# Minimap : émis par base_level._ready() après chargement de la TileMap
# floor_cells : Array[Vector2i] en coordonnées logiques (ASCII pour niveaux générés)
# map_scale   : pixels monde par cellule logique (128 = 8×tile pour générés, 16 pour natifs)
@warning_ignore("unused_signal") signal level_map_ready(floor_cells: Array, map_scale: int)

# Équipe : émis par le joueur actif pour demander un changement de personnage actif
@warning_ignore("unused_signal") signal party_switch_requested(slot: int)
