# Technical Info — Commando Zombi RPG v4

## Système de fichiers JSON par niveau

Chaque niveau charge ses données depuis deux sources, **dans cet ordre de priorité** :

| Priorité | Chemin | Rôle |
|----------|--------|------|
| 1 (lu en premier) | `user://level_x/<fichier>.json` | Sauvegarde de la session en cours |
| 2 (fallback) | `res://Scenes/Levels/level_x/<fichier>.json` | Valeurs par défaut du projet |

Fichiers concernés : `objects.json`, `enemies.json`, `mechas.json`.

### Conséquence pratique

Dès qu'une sauvegarde est effectuée (transition de scène, fermeture du menu, quitter le jeu), le fichier `user://` est créé et **masque définitivement** le fichier `res://` jusqu'à réinitialisation.

### Repositionner un mecha (ou tout objet) pendant le développement

Si tu modifies `res://Scenes/Levels/level_1/mechas.json` mais que le jeu ignore tes nouvelles valeurs, c'est que le fichier `user://` périmé est lu en priorité.

**Solutions :**

1. Supprimer manuellement le fichier user :
   ```bash
   rm ~/.local/share/godot/app_userdata/rpg_v4/level_1/mechas.json
   ```

2. Supprimer tous les fichiers user d'un coup (réinitialisation complète) :
   - Via l'UI du jeu : bouton "Réinitialiser" dans le menu principal (Linux uniquement)
   - Via le code : `liblevel.reinitializeLevel()` — supprime `objects.json`, `enemies.json` et `mechas.json` pour tous les niveaux

3. Activer `GameConfig.DEBUG = true` dans `Autoload/game_config.gd` pour voir dans la console Godot quel fichier est effectivement lu :
   ```
   _read_level_json: lu depuis res://Scenes/Levels/level_1/mechas.json
   ```

### Chemin du dossier user sur Linux

```
~/.local/share/godot/app_userdata/rpg_v4/
```
