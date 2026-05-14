#!/usr/bin/env bash
# Régénère Sprites/Player/sprite_index.json à partir des PNG présents dans items/.
# À exécuter depuis la racine du projet après avoir ajouté ou retiré des PNG.

set -euo pipefail

ITEMS_DIR="Sprites/Player/items"
OUTPUT="Sprites/Player/sprite_index.json"

if [ ! -d "$ITEMS_DIR" ]; then
    echo "Erreur : dossier introuvable : $ITEMS_DIR" >&2
    exit 1
fi

mapfile -t pngs < <(find "$ITEMS_DIR" -maxdepth 1 -name "*.png" | xargs -I{} basename {} | sort)

if [ ${#pngs[@]} -eq 0 ]; then
    echo "Avertissement : aucun PNG trouvé dans $ITEMS_DIR" >&2
    echo "[]" > "$OUTPUT"
    exit 0
fi

{
    echo "["
    for i in "${!pngs[@]}"; do
        if [ $i -lt $((${#pngs[@]} - 1)) ]; then
            printf '  "%s",\n' "${pngs[$i]}"
        else
            printf '  "%s"\n' "${pngs[$i]}"
        fi
    done
    echo "]"
} > "$OUTPUT"

echo "sprite_index.json mis à jour — ${#pngs[@]} fichier(s) :"
printf '  %s\n' "${pngs[@]}"
