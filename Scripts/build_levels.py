"""
build_levels.py — Génère les scènes Godot pour les niveaux 5-10
Reproduit la logique de Scripts/generate_level.gd (EditorScript)
sans nécessiter Godot en ligne de commande.

Usage :
    python3 Scripts/build_levels.py          # génère 5-10
    python3 Scripts/build_levels.py 5 7 9   # génère uniquement les niveaux listés
"""

import re
import json
import os
import sys

# ── Constantes (identiques au GDScript) ───────────────────────────────────────
TILE_PX     = 128   # 8 × 16 px
T           = 8     # tuiles par caractère ASCII (chaque dimension)
GROUND_SRC  = 524288
WALL_SRC    = 327680
TILE_GROUND = 26
TILE_WALL   = 31

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE     = os.path.join(PROJECT_ROOT, "Scenes", "Levels", "level_4", "level_4.tscn")
LEVELS_BASE  = os.path.join(PROJECT_ROOT, "Scenes", "Levels")
MISSIONS     = os.path.join(PROJECT_ROOT, "missions.json")

LEVEL_CFGS = {
    5:  {"uid_scn": "dnvqh8m3p7r2t", "uid_gd": "cxjf9k6m1w4q8", "node_id": 1361413525, "txt": "level_005.txt", "spawn_fb": (12, 25)},
    6:  {"uid_scn": "bm5rw2j9f8n3k", "uid_gd": "cp7t4x1h5n8q2", "node_id": 1361413526, "txt": "level_006.txt", "spawn_fb": (6,  23)},
    7:  {"uid_scn": "dq3f7w9r2m1p5", "uid_gd": "bk8n2x5j4r7w1", "node_id": 1361413527, "txt": "level_007.txt", "spawn_fb": (27,  8)},
    8:  {"uid_scn": "cm6t1p8r4j9n2", "uid_gd": "dw4x7f3m9q5k1", "node_id": 1361413528, "txt": "level_008.txt", "spawn_fb": (21, 12)},
    9:  {"uid_scn": "bp9k5r2m7j4n6", "uid_gd": "cj3q8w1f5x7n4", "node_id": 1361413529, "txt": "level_009.txt", "spawn_fb": (34, 18)},
    10: {"uid_scn": "dt7m4n9r6j2p8", "uid_gd": "bq5j1w8k3n7r2", "node_id": 1361413530, "txt": "level_001.txt", "spawn_fb": (6,  12)},
}

# ── Encodage PackedInt32Array ─────────────────────────────────────────────────
def encode_cell(x: int, y: int) -> int:
    xi = x & 0xFFFF
    yi = y & 0xFFFF
    k = (yi << 16) | xi
    if k >= 0x80000000:
        k -= 0x100000000
    return k

def make_arr(cells: list, src: int, tid: int) -> str:
    if not cells:
        return "PackedInt32Array()"
    nums = []
    for (cx, cy) in cells:
        nums.append(str(encode_cell(cx, cy)))
        nums.append(str(src))
        nums.append(str(tid))
    return "PackedInt32Array(%s)" % ", ".join(nums)

def replace_layer(ct: str, layer: str, arr: str) -> str:
    pattern = re.escape(layer) + r"/tile_data = PackedInt32Array\([^)]*\)"
    replacement = layer + "/tile_data = " + arr
    return re.sub(pattern, replacement, ct)

# ── Lecture et parsing du fichier ASCII ──────────────────────────────────────
def parse_txt(txt_path: str):
    with open(txt_path, encoding="utf-8") as f:
        lines = f.read().split("\n")

    ascii_floor = {}
    sp_ascii = None
    for y, row in enumerate(lines):
        for x, c in enumerate(row):
            if c in ("#", "S", ">"):
                ascii_floor[(x, y)] = c
                if c == "S" and sp_ascii is None:
                    sp_ascii = (x, y)
    return ascii_floor, sp_ascii

def build_tiles(ascii_floor: dict):
    # Murs : cellules vides adjacentes au sol
    ascii_wall = set()
    for (px, py) in ascii_floor:
        for dy in range(-1, 2):
            for dx in range(-1, 2):
                if dx == 0 and dy == 0:
                    continue
                nb = (px + dx, py + dy)
                if nb not in ascii_floor:
                    ascii_wall.add(nb)

    # Expansion T×T par cellule ASCII
    gnd = []
    wll = []
    for (px, py) in ascii_floor:
        for dy in range(T):
            for dx in range(T):
                gnd.append((px * T + dx, py * T + dy))
    for (px, py) in ascii_wall:
        for dy in range(T):
            for dx in range(T):
                wll.append((px * T + dx, py * T + dy))
    return gnd, wll

# ── Génération d'un niveau ─────────────────────────────────────────────────────
def generate_level(n: int) -> None:
    cfg = LEVEL_CFGS[n]
    txt_path = os.path.join(PROJECT_ROOT, "Scripts", cfg["txt"])

    if not os.path.exists(txt_path):
        print(f"  [ERREUR] Fichier manquant : {txt_path}")
        return

    ascii_floor, sp_ascii = parse_txt(txt_path)
    if not ascii_floor:
        print(f"  [ERREUR] Aucune cellule sol dans {txt_path}")
        return

    sp = sp_ascii if sp_ascii else cfg["spawn_fb"]
    if not sp_ascii:
        print(f"  [INFO] Aucun 'S' trouvé — spawn config utilisé : {sp}")

    gnd, wll = build_tiles(ascii_floor)

    # Lecture du template
    with open(TEMPLATE, encoding="utf-8") as f:
        ct = f.read()

    uid_scn = cfg["uid_scn"]
    uid_gd  = cfg["uid_gd"]
    nid     = cfg["node_id"]

    # Substitutions identiques au GDScript
    ct = ct.replace('uid="uid://b46h3lkah31mp"',
                    f'uid="uid://{uid_scn}"')
    ct = ct.replace('uid="uid://b5a8bmiga2obh" path="res://Scenes/Levels/level_4/level_4.gd"',
                    f'uid="uid://{uid_gd}" path="res://Scenes/Levels/level_{n}/level_{n}.gd"')
    ct = ct.replace('[node name="level_4" type="Node2D" unique_id=1361413524]',
                    f'[node name="level_{n}" type="Node2D" unique_id={nid}]')

    ct = replace_layer(ct, "layer_0", make_arr(gnd, GROUND_SRC, TILE_GROUND))
    ct = replace_layer(ct, "layer_1", make_arr(wll, WALL_SRC, TILE_WALL))

    # Répertoire de sortie
    out_dir = os.path.join(LEVELS_BASE, f"level_{n}")
    os.makedirs(out_dir, exist_ok=True)

    # Scène
    _write(os.path.join(out_dir, f"level_{n}.tscn"), ct)

    # Script GDScript (seulement si absent)
    gd_path = os.path.join(out_dir, f"level_{n}.gd")
    if not os.path.exists(gd_path):
        _write(gd_path,
               'extends "res://Scenes/Levels/base_level.gd"\n\nfunc _ready():\n\tsuper._ready()\n')

    # Fichier UID
    _write(os.path.join(out_dir, f"level_{n}.gd.uid"), "uid://" + uid_gd)

    # Fichiers JSON annexes
    half = TILE_PX // 2
    px_spawn = sp[0] * TILE_PX + half
    py_spawn = sp[1] * TILE_PX + half

    objects = [
        {"type": "computer", "x": (sp[0] + 5) * TILE_PX, "y": (sp[1] + 0) * TILE_PX},
        {"type": "computer", "x": (sp[0] + 0) * TILE_PX, "y": (sp[1] + 5) * TILE_PX},
        {"type": "robot",    "x": (sp[0] + 8) * TILE_PX, "y": (sp[1] + 0) * TILE_PX},
        {"type": "robot",    "x": (sp[0] + 0) * TILE_PX, "y": (sp[1] + 8) * TILE_PX},
    ]
    _write_json(os.path.join(out_dir, "objects.json"),          objects)
    _write_json(os.path.join(out_dir, "enemies.json"),           [])
    _write_json(os.path.join(out_dir, "npcs.json"),              [])
    _write_json(os.path.join(out_dir, "level_connections.json"), {"connections": []})

    # Mise à jour missions.json
    _update_mission(n, px_spawn, py_spawn)

    print(f"level_{n} généré ✓  sol:{len(gnd)}  murs:{len(wll)}  spawn:({px_spawn},{py_spawn})px")

# ── Mise à jour missions.json ─────────────────────────────────────────────────
def _update_mission(level_n: int, px: int, py: int) -> None:
    with open(MISSIONS, encoding="utf-8") as f:
        arr = json.load(f)

    target_id    = f"mission_{level_n:02d}"
    target_scene = f"res://Scenes/Levels/level_{level_n}/level_{level_n}.tscn"

    for m in arr:
        if m.get("id") == target_id:
            m["scene"] = target_scene
            m["spawn"] = {"x": px, "y": py}
            break

    with open(MISSIONS, "w", encoding="utf-8") as f:
        json.dump(arr, f, indent="\t", ensure_ascii=False)

# ── I/O ───────────────────────────────────────────────────────────────────────
def _write(path: str, content: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def _write_json(path: str, data) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent="\t", ensure_ascii=False)

# ── Point d'entrée ────────────────────────────────────────────────────────────
if __name__ == "__main__":
    levels = [int(x) for x in sys.argv[1:]] if len(sys.argv) > 1 else list(LEVEL_CFGS.keys())
    for n in levels:
        if n not in LEVEL_CFGS:
            print(f"  [ERREUR] Niveau {n} inconnu (valides : {list(LEVEL_CFGS.keys())})")
            continue
        generate_level(n)
