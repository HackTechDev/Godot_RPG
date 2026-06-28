#!/usr/bin/env python3
"""
download_images.py
==================
Lit le fichier `image_url.txt` (format `clé=url` par ligne) et télécharge
chaque image sous le nom `images/{clé}.jpg`.

Format attendu de image_url.txt :
    weapon_hk416_a5_1=https://example.com/photo1.jpg
    weapon_hk416_a5_2=https://example.com/photo2.jpg
    weapon_hk416_a5_3=https://example.com/photo3.jpg
    ...

- Les lignes vides sont ignorées.
- Les lignes commençant par # sont des commentaires.
- Une ligne sans `=` ou sans URL après le `=` est ignorée (avec un avertissement).
- Le script est idempotent : il saute les fichiers déjà téléchargés.

Usage :
    pip install requests pillow
    python download_images.py
"""

from __future__ import annotations

import sys
import time
from io import BytesIO
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Installe les dépendances : pip install requests pillow")

try:
    from PIL import Image
    HAVE_PIL = True
except ImportError:
    print("[!] Pillow non installé : pas de redimensionnement/conversion JPEG.")
    print("    pip install pillow  (recommandé)")
    HAVE_PIL = False


# ------------------------------ Configuration ------------------------------- #

ROOT = Path(__file__).resolve().parent
URL_FILE = ROOT / "image_url.txt"
IMAGES_DIR = ROOT / "images"

MAX_DIMENSION = 1280       # côté max après redimensionnement (None = pas de redim.)
JPEG_QUALITY = 85
REQUEST_DELAY = 0.3        # secondes entre téléchargements
REQUEST_TIMEOUT = 30
USER_AGENT = "ItemImageDownloader/2.0"


# ----------------------------- Lecture du fichier --------------------------- #

def parse_url_file(path: Path) -> dict[str, str]:
    """Parse image_url.txt → dict {clé: url}. Ignore lignes vides et commentaires."""
    if not path.exists():
        sys.exit(f"Fichier introuvable : {path}")

    entries: dict[str, str] = {}
    duplicates: list[str] = []

    for n, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            print(f"[!] ligne {n} ignorée (pas de '=') : {line[:60]}")
            continue
        key, _, url = line.partition("=")
        key = key.strip()
        url = url.strip()
        if not key or not url:
            print(f"[!] ligne {n} ignorée (clé ou URL vide) : {line[:60]}")
            continue
        if key in entries:
            duplicates.append(key)
        entries[key] = url   # la dernière occurrence gagne

    if duplicates:
        print(f"[!] clés dupliquées (la dernière a été retenue) : {duplicates}")

    return entries


# ----------------------------- Téléchargement ------------------------------- #

def download_to_jpeg(url: str, destination: Path) -> bool:
    """Télécharge l'image et la sauvegarde en JPEG."""
    try:
        r = requests.get(
            url,
            headers={"User-Agent": USER_AGENT},
            timeout=REQUEST_TIMEOUT,
            allow_redirects=True,
        )
        r.raise_for_status()
    except Exception as e:
        print(f"    [x] echec telechargement : {e}")
        return False

    content_type = r.headers.get("Content-Type", "").lower()
    if "image" not in content_type and not HAVE_PIL:
        print(f"    [!] Content-Type suspect ({content_type}) - sauvegarde brute")

    if HAVE_PIL:
        try:
            img = Image.open(BytesIO(r.content))
            if img.mode not in ("RGB", "L"):
                img = img.convert("RGB")
            if MAX_DIMENSION:
                w, h = img.size
                if max(w, h) > MAX_DIMENSION:
                    ratio = MAX_DIMENSION / max(w, h)
                    img = img.resize(
                        (int(w * ratio), int(h * ratio)), Image.LANCZOS
                    )
            img.save(destination, "JPEG", quality=JPEG_QUALITY, optimize=True)
            return True
        except Exception as e:
            print(f"    [x] erreur traitement image : {e}")
            return False
    else:
        # Sans Pillow, on écrit les bytes bruts
        destination.write_bytes(r.content)
        return True


# ------------------------------ Main ---------------------------------------- #

def main() -> int:
    entries = parse_url_file(URL_FILE)
    if not entries:
        sys.exit("Aucune entree valide dans image_url.txt")

    IMAGES_DIR.mkdir(exist_ok=True)

    total = len(entries)
    skipped = 0
    success = 0
    failed = 0

    print(f"\n=== {total} entrees trouvees dans image_url.txt ===\n")

    for idx, (key, url) in enumerate(entries.items(), start=1):
        target = IMAGES_DIR / f"{key}.jpg"

        prefix = f"[{idx}/{total}] {key}"
        if target.exists():
            print(f"{prefix} -> deja present, ignore")
            skipped += 1
            continue

        print(f"{prefix} -> {url[:70]}{'...' if len(url) > 70 else ''}")
        time.sleep(REQUEST_DELAY)
        if download_to_jpeg(url, target):
            print(f"    [v] sauvegarde : images/{key}.jpg")
            success += 1
        else:
            failed += 1

    print(
        f"\n=== Bilan : {success} telechargees | {skipped} deja presentes | "
        f"{failed} echecs ==="
    )
    if failed:
        print("Corrige les URLs problematiques dans image_url.txt et relance.")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
