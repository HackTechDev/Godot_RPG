# Manuel du Joueur — Commando Zombi RPG

**Version du jeu : v4**
*Auteur : Le Sanglier des Ardennes*

---

## Sommaire

1. [Présentation du jeu](#1-présentation-du-jeu)
2. [Premier lancement — créer son personnage](#2-premier-lancement--créer-son-personnage)
3. [Interface en jeu (HUD)](#3-interface-en-jeu-hud)
4. [Contrôles](#4-contrôles)
5. [Se déplacer dans le monde](#5-se-déplacer-dans-le-monde)
6. [Les missions](#6-les-missions)
7. [Objets collectables](#7-objets-collectables)
8. [Les ennemis](#8-les-ennemis)
9. [Système de combat (CQB)](#9-système-de-combat-cqb)
10. [Parler aux PNJ](#10-parler-aux-pnj)
11. [Mode tir](#11-mode-tir)
12. [Vision nocturne](#12-vision-nocturne)
13. [Minimap](#13-minimap)
14. [Piloter un Mecha](#14-piloter-un-mecha)
15. [Jeu en équipe](#15-jeu-en-équipe)
16. [Fiche de personnage](#16-fiche-de-personnage)
17. [Armurerie](#17-armurerie)
18. [Cycle jour / nuit](#18-cycle-jour--nuit)
19. [Menus et paramètres](#19-menus-et-paramètres)
20. [Sauvegarde et réinitialisation](#20-sauvegarde-et-réinitialisation)
21. [Conseils pour débuter](#21-conseils-pour-débuter)

---

## 1. Présentation du jeu

**Commando Zombi RPG** est un jeu de rôle tactique en vue du dessus (top-down 2D). Vous incarnez un mercenaire — ou une équipe de mercenaires — envoyé en mission dans des zones infestées de robots hostiles.

Le jeu repose sur cinq piliers :

- **L'exploration** — parcourez plusieurs secteurs interconnectés.
- **Le combat au tour par tour** — affrontez les ennemis avec un système de dés.
- **La progression** — améliorez votre équipement grâce à l'armurerie.
- **Les missions** — chaque mission propose un scénario, une heure de début et des objectifs précis.
- **Le jeu en équipe** — constituez une escouade de 5 mercenaires et basculez entre eux à tout moment.

---

## 2. Premier lancement — créer son personnage

Au démarrage, le splashscreen s'affiche. Appuyez sur **n'importe quelle touche** ou cliquez pour continuer.

Depuis le menu principal, cliquez sur **Jouer** → **Nouveau personnage** si aucun personnage n'existe encore.

### Page 1 — Identité

- Saisissez votre **surnom** (20 caractères maximum — champ obligatoire).
- Rédigez une **biographie** libre qui décrit votre mercenaire.

### Page 2 — Apparence

Choisissez l'aspect visuel de votre personnage couche par couche :
Corps, Cheveux, Casque, Bras, Mains, Torse, Jambes, Pieds.

La prévisualisation (fond blanc, zoom ×3) se met à jour en temps réel à chaque changement.

### Page 3 — Profil militaire

- Sélectionnez votre **grade** parmi quatre catégories (du militaire du rang à l'officier général).
- Choisissez une **spécialisation** dans la liste :

| Spécialisation | Description rapide |
|---|---|
| Opérateur FS | Forces spéciales polyvalentes |
| Tireur de précision | Engagement à longue distance |
| Transmetteur | Communication et renseignement électronique |
| Démineur / EOD | Neutralisation d'engins explosifs |
| Médecin de combat | Maintien en condition opérationnelle |
| Renseignement | Collecte et analyse d'informations |
| Spéc. insertion | Infiltration discrète |
| Spéc. appuis | Coordination des appuis feux |

Un panneau descriptif détaille chaque spécialisation à droite de la liste.

### Page 4 — Statistiques

Répartissez **60 points** entre 11 attributs (maximum **20 points** par attribut). Le compteur de points restants s'affiche en temps réel.

| Attribut | Effet en jeu |
|---|---|
| **Santé** | Points de vie (valeur par défaut : 10) |
| **Attaque** | Seuil de réussite des jets d'attaque au combat |
| **Défense** | Seuil de réussite des jets de défense au combat |
| **Endurance** | Résistance à la fatigue et aux effets de statut |
| **Discrétion** | Difficulté à être repéré par les ennemis |
| **Vitesse** | Agility et réactivité |
| **Précision** | Efficacité du tir à distance |
| **Force** | Puissance physique — influence le corps-à-corps |
| **Intelligence** | Capacité d'analyse et de résolution |
| **Capacité de charge** | Poids maximum transportable sans pénalité |
| **Mouvement (×20 pts)** | Chaque point alloué = +20 pts de jauge de mouvement |

> La jauge de mouvement se consomme en marchant et est affichée en temps réel dans le HUD.

Une fois satisfait, cliquez sur **Créer le personnage** : le jeu démarre directement.

---

## 3. Interface en jeu (HUD)

### Panneau en haut à gauche

Affiché en permanence pendant la partie :

| Indicateur | Description |
|---|---|
| **Pseudo** | Surnom du personnage actif |
| **Santé** | Points de vie actuels |
| **Mvt** | Jauge de mouvement actuelle / maximum |
| **Ordinateurs** | Nombre d'ordinateurs collectés |
| **Robots** | Nombre de robots collectables récupérés |
| **Zone** | Nom du secteur actuel |
| **Pos** | Coordonnées x, y du joueur sur la carte |
| **Mode** | Mode de déplacement actif (1-Marche / 2-Accroupi / 3-Course) |

### Horloge de mission

Affichée en haut au centre de l'écran. Elle indique la **date et l'heure in-game** au format `JJ/MM/AAAA HHhMM`. À gauche de l'étiquette, un **cadran soleil/lune** représente la progression du temps entre lever et coucher du soleil.

> 1 minute réelle = 1 heure de jeu.

L'horloge se **met en pause** lorsqu'un menu est ouvert (Fiche, Paramètres, menu radial…).

### Barre de boutons (haut à droite)

| Bouton | Effet |
|---|---|
| **Fiche** | Ouvre la fiche de personnage |
| **Transfert ↔** | Ouvre le panneau de transfert d'équipement entre membres |
| **Armurerie** | Ouvre l'armurerie |
| **Paramètres** | Ouvre le menu des paramètres |
| **Accueil** | Ouvre le menu principal |

> En mode tir actif, les boutons du HUD sont temporairement désactivés.

---

## 4. Contrôles

### Déplacement

| Touche | Action |
|---|---|
| Flèches / ZQSD | Déplacer le personnage |
| **Pavé num. 4 / 6** | Faire pivoter le corps (±45°) |
| **Pavé num. 7 / 9** | Faire pivoter le regard (±45°, limité à ±90° du corps) |
| **1** | Mode Marche (vitesse normale) |
| **2** | Mode Accroupi (vitesse réduite, discrétion accrue) |
| **3** | Mode Course (vitesse élevée) |
| **Shift + direction** | Panoramique caméra (le personnage reste immobile) |

> Orienter le regard différemment du corps réduit la vitesse à la moitié. Gardez corps et regard alignés pour vous déplacer vite.

### Actions en jeu

| Touche | Action |
|---|---|
| **T** | Ramasser un objet à portée |
| **R** | Pousser un objet dans la direction du regard |
| **Z** | Parler à un PNJ à portée |
| **C** | Engager / fuir un combat contre un ennemi proche |
| **A** | Attaquer (pendant le combat) |
| **Espace** | Lancer les dés au combat / Confirmer une transition de zone |
| **B** | Construire un ordinateur |
| **M** | Monter / descendre d'un Mecha |
| **Échap** | Quitter le combat / fermer le menu radial |
| **H** | Aide — affiche la liste des contrôles |

### Menus

| Touche | Action |
|---|---|
| **P** | Ouvrir / fermer la fiche de personnage |
| **Clic gauche sur le personnage** | Ouvrir le menu radial |

### Jeu en équipe

| Touche | Action |
|---|---|
| **Shift + 1** | Basculer vers le membre du slot 1 (chef) |
| **Shift + 2** | Basculer vers le membre du slot 2 |
| **Shift + 3** | Basculer vers le membre du slot 3 |
| **Shift + 4** | Basculer vers le membre du slot 4 |
| **Shift + 5** | Basculer vers le membre du slot 5 |

### Menu radial

Un clic gauche **sur votre sprite** ouvre un menu circulaire avec les actions disponibles :

| Icône | Action |
|---|---|
| **B — Construire** | Place un ordinateur à la position du joueur |
| **T — Ramasser** | Collecte l'objet au contact |
| **Z — Parler** | Ouvre le dialogue avec le PNJ proche |
| **C — Combat** | Engage le combat avec l'ennemi proche |
| **P — Fiche** | Bascule la fiche de personnage |
| **A — Attaquer** | Attaque (en combat uniquement) |
| **F — Tirer** | Active / désactive le mode tir |
| **N — Nuit** | Active / désactive la vision nocturne |
| **M — Carte** | Affiche / masque la minimap |

---

## 5. Se déplacer dans le monde

### Modes de déplacement

Appuyez sur **1**, **2** ou **3** pour changer de mode :

| Touche | Mode | Vitesse (aligné) | Vitesse (décalé) |
|---|---|---|---|
| **1** | Marche | 70 px/s | 35 px/s |
| **2** | Accroupi | 20 px/s | 20 px/s |
| **3** | Course | 130 px/s | 55 px/s |

Le mode actif est affiché dans le HUD sous "Pos".

### Panoramique caméra

Maintenez **Shift** et appuyez sur une direction pour déplacer la vue sans bouger votre personnage. La caméra revient doucement sur le joueur quand vous relâchez Shift.

### Changer de zone

Le monde est divisé en **secteurs** interconnectés. Pour passer d'un secteur à l'autre :

1. Repérez les **zones de sortie** — rectangles orange semi-transparents sur le sol.
2. Positionnez votre personnage dans la zone.
3. Appuyez sur **Espace** pour déclencher la transition.

Un écran de chargement s'affiche brièvement ; votre position relative dans la zone est préservée à l'arrivée. Un délai de 0,5 s s'applique après l'arrivée pour éviter un déclenchement immédiat.

---

## 6. Les missions

### Sélectionner un personnage et une mission

Depuis le menu principal → **Jouer** :

1. L'écran de **sélection de personnage** liste vos mercenaires existants.
2. Cliquez sur un personnage. Si une mission est en cours, un récapitulatif s'affiche — vous pouvez la reprendre ou en choisir une autre.
3. Sur l'écran de **sélection de mission**, cliquez sur une mission pour voir son titre, sa date de début, sa description et ses objectifs.
4. Cliquez sur **Accepter** pour lancer la mission.

### Missions disponibles

| # | Titre | Heure de début | Résumé |
|---|---|---|---|
| 01 | Opération Aube Rouge | 06:00 | Sécuriser la zone industrielle nord |
| 02 | Extraction Foxtrot | 14:30 | Localiser et évacuer un agent bloqué |
| 03 | Dernier Rempart | 22:00 | Renforcer la dernière ligne de défense |
| 04 | Opération Marteau Gris | 05:30 | Neutraliser les patrouilles et sécuriser une cache d'armement |
| 05 | Nuit Blanche | 23:45 | Infiltration nocturne — signaux radio mystérieux |
| 06 | Zone Delta | 12:00 | Reprendre le couloir stratégique Delta |
| 07 | Évacuation Bravo | 15:15 | Escorter des civils assiégés |
| 08 | Protocole Oméga | 20:00 | Récupérer des données classifiées |
| 09 | Chasse aux Fantômes | 08:45 | Détruire les brouilleurs de signal |
| 10 | Forteresse Assiégée | 02:30 | Percer les lignes ennemies et ravitailler le poste Kilo-4 |

> **Astuce débutant :** Commencez par la mission 01 (Opération Aube Rouge), qui débute en plein jour.

### Gestion des personnages

Depuis l'écran de sélection de personnage, le bouton **Gérer** ouvre le gestionnaire complet. Vous pouvez y :
- Consulter la progression de chaque personnage (mission en cours, temps joué, date de dernière sauvegarde).
- Lancer directement une partie avec le bouton **Jouer ▶**.
- Supprimer définitivement un personnage (confirmation demandée).

---

## 7. Objets collectables

Deux types d'objets sont éparpillés dans les niveaux :

| Objet | Touche | Effet |
|---|---|---|
| **Ordinateur** | T (à portée) | Incrémente le compteur d'ordinateurs, ajouté à l'inventaire |
| **Robot** (collectable) | T (à portée) | Incrémente le compteur de robots, ajouté à l'inventaire |

### Interagir avec un objet

Approchez-vous. Quand vous êtes à portée, le label **"T : Prendre / R : Pousser"** s'affiche sur l'objet.

- **T** — Ramasser l'objet (il disparaît et s'ajoute à l'inventaire).
- **R** — Pousser l'objet dans la direction du regard (physique temps réel).

Les positions des objets poussés sont **sauvegardées automatiquement** à la fermeture du menu ou lors d'un changement de zone.

À chaque collecte, un message bref ("Ordinateur collecté !") apparaît en haut de l'écran pendant 1,5 s.

---

## 8. Les ennemis

### Robots ennemis

Les robots ennemis sont identifiables par leur **teinte rouge** et leur **cône de vision rouge** (120°).

**Comportement :**
- Ils détectent le joueur s'il entre dans leur cône de vision.
- Une fois détecté, ils se déplacent vers vous à 35 px/s.
- Au contact hors combat, ils infligent des dégâts passifs.

**En combat**, le cône est masqué et les règles du CQB s'appliquent.

---

## 9. Système de combat (CQB)

Le combat se déroule **au tour par tour** avec un système de dés inspiré des JDR classiques.

### Engager le combat

1. Approchez-vous d'un ennemi (≈ 70 px).
2. Appuyez sur **C** pour engager. Un overlay s'affiche — le mouvement est bloqué.

### Déroulement d'un round

```
1. VOUS ATTAQUEZ
   → [Espace] pour lancer le dé (1–20)
   → Résultat < votre Attaque = succès → l'ennemi tente de se défendre
   → Résultat ≥ votre Attaque = raté → l'ennemi contre-attaque

2. L'ENNEMI SE DÉFEND (si votre attaque a réussi)
   → Lancer automatique
   → Défense réussie → attaque bloquée → l'ennemi attaque
   → Défense échouée → l'ennemi perd 1 PV
       • PV ennemi ≤ 0 → ennemi éliminé, combat terminé
       • Sinon → vous counter-attaquez

3. L'ENNEMI ATTAQUE (automatique)
   → Attaque réussie → vous défendez

4. VOUS VOUS DÉFENDEZ (si l'attaque ennemie a réussi)
   → [Espace] pour lancer le dé
   → Défense réussie → vous counter-attaquez
   → Défense échouée → vous perdez 1 PV
       • PV ≤ 0 → GAME OVER
       • Sinon → l'ennemi attaque à nouveau
```

### Tenter de fuir

Pendant le combat, appuyez à nouveau sur **C** :
- Tirage interne (1–10) > 5 → fuite réussie.
- ≤ 5 → fuite ratée → l'ennemi contre-attaque immédiatement.

### Quitter sans résolution

**Échap** quitte le combat immédiatement sans pénalité.

### Game Over

Si vos PV tombent à 0 :
- L'overlay affiche **GAME OVER**.
- Appuyez sur **Espace** pour recommencer.
- Vous serez redirigé vers la création de personnage pour repartir à zéro.

---

## 10. Parler aux PNJ

Les personnages non-joueurs (PNJ) sont repérables à leur **teinte verte** et au nom affiché au-dessus d'eux.

1. Approchez-vous jusqu'à voir le label **"Z : Parler"**.
2. Appuyez sur **Z** (ou menu radial → Z).
3. La boîte de dialogue s'ouvre en bas de l'écran.

Cliquez sur un **choix** pour orienter la conversation. Le dialogue se termine quand il n'y a plus de suite. Le mouvement est bloqué pendant un dialogue actif.

> **Exemple :** Dans la zone 1, le **Commandant Dubois** donne des renseignements sur la position des ennemis.

---

## 11. Mode tir

Le mode tir permet d'engager des ennemis à distance sans entrer en CQB.

### Activer le mode tir

Ouvrez le menu radial (clic gauche sur votre sprite) → **F — Tirer**. Un **réticule rouge** apparaît à l'écran et le curseur de la souris est masqué.

> Les boutons du HUD sont désactivés pendant le mode tir.

### Viser et tirer

- Déplacez la souris pour positionner le réticule.
- Une **ligne rouge** est tracée du joueur au réticule — elle indique la ligne de tir.
  - Si la ligne rencontre un mur, elle s'arrête au point d'impact.
  - Si le réticule est **hors du cône de vision** (±45° du regard), la ligne n'est pas tracée : le tir est impossible.
- **Clic gauche** pour tirer (un seul clic par balle).

### Détection de partie du corps

Quand le réticule survole un ennemi ou un PNJ, la **partie du corps ciblée** est affichée en texte jaune à droite du réticule (Tête, Torse, Bras, Mains, Jambes, Pieds).

### Désactiver le mode tir

Rouvrez le menu radial → **F — Tirer** pour désactiver, ou appuyez sur **Échap**.

> **Conseil :** Activez l'affichage de la ligne rouge dans **Paramètres → Debug** pour mieux juger la ligne de tir.

---

## 12. Vision nocturne

La vision nocturne est un effet visuel qui améliore la lisibilité de la scène dans l'obscurité.

### Activer

Menu radial → **N — Nuit**. Un filtre vert type NVG s'applique à l'intérieur du **cône de vision** du personnage — la zone hors cône reste dans l'obscurité normale.

Le filtre suit en temps réel la rotation du regard et le déplacement de la caméra.

### Désactiver

Menu radial → **N — Nuit** à nouveau.

---

## 13. Minimap

### Afficher la minimap

Menu radial → **M — Carte**. La minimap apparaît dans le **coin inférieur droit** (200×100 px). Elle représente le plan du niveau actuel avec un **brouillard de guerre** : seules les zones déjà visitées (rayon de 5 cellules autour du joueur) sont révélées.

### Agrandir la minimap

**Clic gauche sur la minimap** pour l'agrandir (600×400 px, centrée à l'écran). Un second clic la remet en format compact.

### Masquer la minimap

Menu radial → **M — Carte** à nouveau.

> La minimap se réinitialise à l'entrée dans chaque nouveau niveau.

---

## 14. Piloter un Mecha

Des Mechas (robots de combat) sont présents dans certains niveaux.

### Monter

1. Approchez-vous jusqu'à voir le label **"M : Piloter"**.
2. Appuyez sur **M** : votre sprite est masqué, la caméra zoome légèrement en arrière (×0,8).

### Déplacement

Les commandes restent les mêmes (Flèches / WASD). Le Mecha se déplace avec **inertie** : il accélère et décélère progressivement. Un son de moteur joue pendant le déplacement.

### Descendre

Appuyez à nouveau sur **M**. Le jeu calcule automatiquement une position de sortie sûre (hors des murs) puis votre sprite réapparaît.

> Un court délai s'applique avant de pouvoir remonter après être sorti.

---

## 15. Jeu en équipe

### Constituer une équipe

Depuis le menu principal → **Jouer** → sélectionnez un personnage → **Gérer** :
- Le bouton **"Équipe +"** ajoute un autre personnage en tant que membre de l'escouade.
- Le bouton **"Quitter équipe"** le retire.
- La section **"ÉQUIPE ACTIVE"** affiche toujours les 5 slots.

### Changer de personnage actif

En jeu, appuyez sur **Shift + N** (N = numéro du slot, de 1 à 5) pour basculer vers ce membre.

- Un **flash au noir** (0,15 s) marque le switch.
- La caméra se recentre automatiquement sur le nouveau personnage actif.
- Un **cooldown de 1,5 s** s'applique entre deux switches — tentative pendant ce délai → flash orange.

Les membres inactifs restent visibles dans le niveau en animation idle.

### Indicateurs visuels de l'équipe

Un label flottant s'affiche au-dessus de chaque membre :

| Couleur | Slot |
|---|---|
| Cyan-vert | Chef (slot 1) |
| Orange | Slot 2 |
| Violet | Slot 3 |
| Jaune | Slot 4 | 
| Rouge | Slot 5 |

Le personnage actif affiche `▶ Nom`, les inactifs affichent `N Nom`.

### Transférer de l'équipement

Deux points d'accès au panneau de transfert :
- Bouton **"Transfert ↔"** dans la barre du HUD.
- Bouton dans le gestionnaire de personnages (menu principal).

Le panneau propose :
1. Deux menus déroulants **FROM** / **TO** — sélectionnez les deux membres concernés.
2. La liste des objets de l'inventaire source avec un bouton **"Transférer ↔"** par item.

### Stats individuelles

Chaque membre possède ses propres statistiques (santé, attaque, défense, mouvement…) sauvegardées indépendamment. Elles sont conservées lors des switches.

---

## 16. Fiche de personnage

**Ouvrir la fiche :**
- Bouton **Fiche** dans la barre du HUD, ou touche **P**.

La fiche comporte quatre onglets :

### Onglet Statistiques

| Information | Description |
|---|---|
| Pseudo | Surnom du personnage |
| Santé | Points de vie actuels / maximum |
| Mouvement | Jauge de mouvement actuelle / maximum |
| Attaque | Valeur d'attaque au combat |
| Défense | Valeur de défense au combat |
| Grade | Grade militaire |
| Spécialisation | Rôle choisi à la création |
| Crédits | Solde disponible (en ¤) |

### Onglet Inventaire

Liste de tous les objets collectés (ordinateurs, robots). Chaque entrée affiche le type et le nom de l'objet.

### Onglet Apparence

Modifiez l'apparence de votre personnage **en cours de partie** sans passer par le wizard de création.

- 8 slots configurables : Corps, Cheveux, Couvre-chef, Bras, Gants, Torse, Jambes, Pieds.
- La prévisualisation se met à jour en temps réel.
- Les changements sont appliqués immédiatement en jeu et sauvegardés automatiquement.

### Onglet Photos

Jusqu'à **3 photos** par personnage :
- Cliquez sur **"+"** sous un slot pour importer une image depuis votre disque (PNG, JPG, JPEG).
- Cliquez sur **"✕"** pour supprimer une photo.

Les photos sont stockées dans le dossier de sauvegarde du personnage.

---

## 17. Armurerie

Achetez et équipez votre mercenaire avec vos **crédits (¤)**.

**Ouvrir l'armurerie :** bouton **Armurerie** dans la barre du HUD.

### Catégories

| Catégorie | Contenu |
|---|---|
| **Armes** | Pistolets, fusils, armes de corps-à-corps |
| **Protections** | Gilets, casques, boucliers balistiques |
| **Matériels** | Gadgets (vision nocturne, fumigènes, trousses médicales…) |
| **Vêtements** | Tenues tactiques, camouflages, uniformes |

Cliquez sur une catégorie puis sur un article pour afficher sa fiche de détail à droite. Certains articles disposent de **photos** navigables (boutons **< N/total >** sous l'image).

### Acheter

1. Sélectionnez un article.
2. Vérifiez son prix dans la fiche de détail.
3. Si vous avez suffisamment de crédits, cliquez sur **Acheter (X ¤)**.

> Si vous n'avez pas assez de crédits, le bouton est désactivé.
> Si vous possédez déjà l'objet, le bouton affiche "Déjà possédé".

### Vendre

Sélectionnez un article déjà possédé → **Vendre (X ¤)** pour récupérer son prix d'achat.

### Crédits de départ

Vous démarrez avec **1 000 ¤**.

---

## 18. Cycle jour / nuit

Chaque mission se déroule à une heure précise et le temps s'écoule en temps réel.

- 1 minute réelle = 1 heure de jeu.
- Le monde s'assombrit progressivement à l'approche du coucher du soleil (overlay bleu nuit, alpha 0→0,85).
- L'aube ramène la luminosité normale avec la même transition progressive.
- Le **cadran soleil/lune** sur le HUD représente visuellement la position du soleil dans sa course.

Les heures de lever et coucher varient selon la mission. Certaines missions commencent de nuit — équipez-vous en conséquence (gadgets de vision nocturne à l'armurerie, ou utilisez le mode tir via le menu radial).

> L'horloge se met en pause lorsque vous ouvrez un menu.

---

## 19. Menus et paramètres

### Menu principal

Accessible via le bouton **Accueil** du HUD.

| Option | Description |
|---|---|
| **Retour au jeu** | Reprend la partie sans recharger (disponible en cours de partie) |
| **Jouer** | Accède à la sélection de personnage puis de mission |
| **Paramètres** | Ouvre les paramètres |
| **Aide** | Affiche la liste des contrôles |
| **Quitter** | Demande confirmation, affiche les crédits puis ferme le jeu |

### Paramètres — Audio

- **Musique** : activer / désactiver la musique de fond.
- **Volume musique** : slider de 0 à 100.
- **Musique intro / crédits** : activer / désactiver la musique sur le splashscreen et les crédits.
- **Effets sonores** : activer / désactiver les bruits de pas et effets.
- **Volume effets** : slider de 0 à 100.

### Paramètres — Vidéo

- **Plein écran** : basculer entre mode fenêtré et plein écran.
- Cliquez sur **Appliquer** pour valider le changement.

### Paramètres — Contrôles

Tableau complet de toutes les touches du jeu.

### Paramètres — Debug

- **Afficher le cône et la flèche** : masque / affiche le cône de vision vert et la flèche de direction orange.
- **Afficher la ligne rouge de la cible** : masque / affiche la ligne de tir en mode visée.

### Réinitialiser

Réinitialise toutes les sauvegardes depuis les fichiers par défaut. Vous serez renvoyé vers la **création de personnage**.

> **Attention :** Cette action efface votre progression (position, inventaire, équipements, crédits).

---

## 20. Sauvegarde et réinitialisation

### Sauvegarde automatique

La partie est sauvegardée automatiquement dans les situations suivantes :

- À la **fermeture du menu** principal (bouton Accueil).
- Lors d'un **changement de zone** (transition entre niveaux).
- Lors d'un **switch de personnage** (Shift+N).
- Lors d'un **achat ou d'une vente** à l'armurerie.
- À la **confirmation de quitter** le jeu.

Il n'y a pas de sauvegarde manuelle.

### Multi-personnages

Chaque personnage possède son propre dossier de sauvegarde (`user://characters/<slug>/`). Les positions, stats et inventaires de tous les membres de l'équipe sont sauvegardés indépendamment.

### Charger la partie

Menu principal → **Jouer** → sélectionnez votre personnage → reprenez la mission en cours ou choisissez-en une nouvelle.

### Réinitialiser la progression

Menu principal → **Paramètres** → **Réinitialiser** (ou bouton en jeu depuis le menu principal).

---

## 21. Conseils pour débuter

### Conseils généraux

- **Explorez prudemment** : les ennemis ont un cône de vision rouge. Contournez-les par les flancs.
- **Surveillez votre jauge de mouvement** : elle diminue en marchant. Restez en mode Marche pour la conserver plus longtemps.
- **Parlez aux PNJ** : ils donnent des informations précieuses sur les objectifs.
- **Gérez vos crédits** : vous démarrez avec 1 000 ¤. Priorité aux protections et aux soins.

### Conseils de combat

- **Investissez dans la Défense** : bloquer les attaques ennemies est aussi crucial qu'attaquer.
- **Prenez votre temps** : lisez le message de l'overlay avant d'appuyer sur Espace pour lancer le dé.
- **Utilisez la fuite (C)** si vous êtes en mauvaise posture — 50 % de réussite vaut mieux que perdre le dernier PV.
- **Évitez le contact passif** : les ennemis infligent des dégâts au contact hors combat. Engagez le CQB (C) plutôt que de vous laisser toucher sans réagir.

### Conseils de déplacement

- **Alignez corps et regard** pour vous déplacer à pleine vitesse.
- **Mode accroupi (2)** pour vous faufiler discrètement près des ennemis.
- **Mode panoramique (Shift + direction)** pour observer la zone avant d'avancer.
- **Consultez la minimap (M)** pour ne pas vous perdre dans les grands niveaux générés.

### Conseils sur l'armurerie

- **Commencez par les protections** : réduire les dégâts reçus allonge considérablement votre survie.
- **Comparez les pénalités de mobilité** : une armure lourde ralentit et compromet les retraites.
- **Les gadgets sont situationnels** : un kit de vision nocturne est inutile en plein jour mais indispensable pour les missions nocturnes (03, 05, 10).

### Conseils sur le jeu en équipe

- **Dispersez vos points de stat** entre les membres : un personnage orienté Défense, un autre Attaque.
- **Switchez avant de prendre des dégâts** : si un membre est en mauvaise posture en combat, fuyez (C + Échap) puis basculez sur un autre.
- **Utilisez le transfert d'équipement** pour optimiser la répartition du matériel selon les capacités de charge de chaque membre.

### Indicateurs visuels

| Couleur | Signification |
|---|---|
| Cône **vert** | Champ de vision du joueur |
| Flèche **orange** | Direction du corps du joueur |
| Cône **rouge** | Champ de vision d'un ennemi |
| Rectangle **orange** | Zone de transition vers un autre secteur |
| Filtre **vert NVG** | Vision nocturne active |

---

*Manuel rédigé pour Commando Zombi RPG v4 — Le Sanglier des Ardennes*
*samuel.gondouin@gmail.com*
