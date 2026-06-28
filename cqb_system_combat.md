# Système de combat au corps à corps (CQB)

## Déclenchement

- Le joueur appuie sur **C** à proximité d'un robot ennemi pour engager le combat.
- Le mouvement du joueur est bloqué pendant toute la durée du combat.
- Appuyer sur **Échap** quitte le combat immédiatement sans résolution.

---

## Statistiques

| Statistique   | Joueur              | Robot ennemi         |
|---------------|---------------------|----------------------|
| Points de vie | 4 (fixe au départ)  | 2 à 3 (aléatoire)    |
| Attaque       | 10–15 (aléatoire)   | 10–15 (aléatoire)    |
| Défense       | 10–15 (aléatoire)   | 10–15 (aléatoire)    |

---

## Lancer de dé

- Tous les lancers produisent un nombre aléatoire entre **1 et 20**.
- Un défilement animé de valeurs est affiché avant le résultat final.
- **Lancer du joueur** : le joueur appuie sur **Espace** pour déclencher le lancer.
- **Lancer du robot** : automatique, sans intervention du joueur.
- Un résultat est **réussi** si la valeur obtenue est **strictement inférieure** à la statistique concernée.

---

## Déroulement d'un tour

### 1. Attaque du joueur

1. L'overlay affiche **"Le joueur attaque !"**
2. Le joueur appuie sur **Espace** → lancer de dé (1–20)
3. **Si résultat < Attaque du joueur** → Attaque réussie → passer à l'étape 2
4. **Sinon** → Attaque ratée → le robot contre-attaque (voir section **Attaque du robot**)

### 2. Défense du robot (suite d'une attaque réussie du joueur)

1. L'overlay affiche **"Le robot tente de se défendre..."**
2. Lancer automatique (1–20)
3. **Si résultat < Défense du robot** → Défense réussie, attaque bloquée → le robot attaque à son tour (voir section **Attaque du robot**)
4. **Sinon** → Défense échouée → le robot perd **1 PV**
   - Si PV robot ≤ 0 → **robot éliminé**, combat terminé
   - Sinon → le joueur contre-attaque (retour à l'étape **Attaque du joueur**, avec le message "Le joueur contre-attaque !")

---

## Attaque du robot

1. L'overlay affiche **"Le robot attaque !"**
2. Lancer automatique (1–20)
3. **Si résultat ≥ Attaque du robot** → Attaque ratée → le joueur contre-attaque (voir **Contre-attaque du joueur**)
4. **Sinon** → Attaque réussie → passer à la défense du joueur

### Défense du joueur (suite d'une attaque réussie du robot)

1. L'overlay affiche **"Le joueur tente de se défendre..."**
2. Le joueur appuie sur **Espace** → lancer de dé (1–20)
3. **Si résultat < Défense du joueur** → Défense réussie → le joueur contre-attaque (voir **Contre-attaque du joueur**)
4. **Sinon** → Défense échouée → le joueur perd **1 PV**
   - Si PV joueur ≤ 0 → **Game Over**
   - Sinon → le robot attaque à nouveau (retour à **Attaque du robot**)

---

## Contre-attaque du joueur

Déclenchée quand :
- Le robot a raté son attaque, ou
- Le joueur a réussi sa défense.

Suit les mêmes règles que **Attaque du joueur** (message : "Le joueur contre-attaque !").

---

## Fuite

- Le joueur appuie sur **C** pendant le combat pour tenter de fuir.
- Lancer interne (1–10) : résultat > 5 → fuite réussie, combat terminé.
- Résultat ≤ 5 → fuite ratée → le robot attaque immédiatement.

---

## Game Over

- Affiché quand les PV du joueur atteignent 0 pendant le combat.
- L'overlay affiche **"GAME OVER"**.
- Le joueur appuie sur **Espace** → réinitialisation complète du jeu et retour au menu principal.

---

## Contrôles récapitulatifs

| Touche   | Action                                      |
|----------|---------------------------------------------|
| C        | Engager le combat / Tenter de fuir          |
| Espace   | Lancer le dé / Continuer / Recommencer      |
| Échap    | Quitter le combat immédiatement             |
