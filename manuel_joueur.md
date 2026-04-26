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
11. [Piloter un Mecha](#11-piloter-un-mecha)
12. [Fiche de personnage](#12-fiche-de-personnage)
13. [Armurerie](#13-armurerie)
14. [Cycle jour / nuit](#14-cycle-jour--nuit)
15. [Menus et paramètres](#15-menus-et-paramètres)
16. [Sauvegarde et réinitialisation](#16-sauvegarde-et-réinitialisation)
17. [Conseils pour débuter](#17-conseils-pour-débuter)

---

## 1. Présentation du jeu

**Commando Zombi RPG** est un jeu de rôle tactique en vue du dessus (top-down 2D). Vous incarnez un mercenaire envoyé en mission dans des zones infestées de zombies et de robots hostiles.

Le jeu repose sur quatre piliers :

- **L'exploration** — parcourez plusieurs secteurs interconnectés.
- **Le combat au tour par tour** — affrontez les ennemis avec un système de dés.
- **La progression** — améliorez votre équipement grâce à l'armurerie.
- **Les missions** — chaque mission propose un scénario et des objectifs précis.

---

## 2. Premier lancement — créer son personnage

Au démarrage, le splashscreen s'affiche. Appuyez sur **n'importe quelle touche** ou cliquez pour continuer.

Depuis le menu principal, cliquez sur **Jouer** puis **Créer un personnage** si aucun personnage n'existe encore.

### Page 1 — Identité

- Saisissez votre **surnom** (20 caractères maximum).
- Rédigez une **biographie** libre qui décrit votre mercenaire.

### Page 2 — Apparence

- Choisissez l'aspect visuel de votre personnage couche par couche :
  - Corps, Cheveux, Casque, Bras, Mains, Torse, Jambes, Pieds.
- La prévisualisation se met à jour en temps réel.

### Page 3 — Profil militaire

- Sélectionnez votre **grade** parmi quatre catégories (du militaire du rang à l'officier général).
- Choisissez une **spécialisation** dans la liste :
  - Opérateur FS, Tireur de précision, Transmetteur, Démineur/EOD, Médecin de combat, Renseignement, Spéc. insertion, Spéc. appuis.
- Un panneau descriptif détaille chaque spécialisation à droite.

### Page 4 — Statistiques

Répartissez **30 points** entre trois attributs :

| Attribut | Effet |
|---|---|
| **Santé** | Points de vie de départ. Atteignez 0 = Game Over. |
| **Attaque** | Seuil de réussite lors des jets d'attaque au combat. |
| **Défense** | Seuil de réussite lors des jets de défense au combat. |

Le compteur de points restants s'affiche en temps réel. Vous ne pouvez pas valider si des points restent non attribués.

Une fois satisfait, cliquez sur **Créer le personnage** : le jeu démarre directement.

---

## 3. Interface en jeu (HUD)

### Panneau en haut à gauche

Affiché en permanence pendant la partie :

| Indicateur | Description |
|---|---|
| **Pseudo** | Surnom de votre personnage |
| **Santé** | Points de vie actuels |
| **Ordinateurs** | Nombre d'ordinateurs collectés |
| **Robots** | Nombre de robots collectables récupérés |
| **Zone** | Nom du secteur actuel |
| **Pos** | Coordonnées x, y du joueur sur la carte |

### Horloge de mission

Affichée en haut au centre de l'écran. Elle indique la **date et l'heure in-game** au format `JJ/MM/AAAA HHhMM`.

> 1 minute réelle = 1 heure de jeu.

### Barre de boutons (haut à droite)

| Bouton | Raccourci | Effet |
|---|---|---|
| **Fiche** | — | Ouvre la fiche de personnage |
| **Armurerie** | — | Ouvre l'armurerie |
| **Paramètres** | — | Ouvre le menu des paramètres |
| **Accueil** | — | Ouvre le menu principal |

---

## 4. Contrôles

### Déplacement

| Touche | Action |
|---|---|
| Flèches directionnelles / ZQSD | Déplacer le personnage |
| **Pavé num. 4 / 6** | Faire pivoter le corps (±45°) |
| **Pavé num. 7 / 9** | Faire pivoter le regard (±45°, limité à ±90° du corps) |

> **Astuce :** Orienter le regard différemment du corps (pavé numérique) réduit votre vitesse de déplacement à 35 px/s au lieu de 70 px/s. Gardez votre corps aligné avec votre direction de marche pour vous déplacer vite.

### Actions

| Touche | Action |
|---|---|
| **T** | Ramasser un objet à portée |
| **R** | Pousser un objet dans la direction du regard |
| **Z** | Parler à un PNJ à portée |
| **C** | Engager / fuir un combat contre un ennemi proche |
| **Espace** | Lancer les dés au combat / Confirmer / Changer de zone |
| **B** | Construire un ordinateur (placement) |
| **M** | Monter / descendre d'un Mecha |
| **Échap** | Quitter le combat en cours |

### Menus

| Touche | Action |
|---|---|
| **P** | Ouvrir / fermer la fiche de personnage |
| **Clic gauche sur le personnage** | Ouvrir le menu radial |

### Menu radial

Un clic gauche **sur votre sprite** ouvre un menu circulaire avec 6 actions rapides :

| Icône | Équivalent clavier |
|---|---|
| B — Construire | B |
| T — Ramasser | T |
| Z — Parler | Z |
| C — Combat | C |
| P — Fiche | P |
| A — Attaquer | A (combat uniquement) |

---

## 5. Se déplacer dans le monde

Le monde est divisé en **zones** (secteurs). Pour passer d'une zone à l'autre :

1. Repérez les **zones de sortie** — elles sont signalées par un rectangle orange semi-transparent sur le sol.
2. Positionnez votre personnage dans la zone de sortie.
3. Appuyez sur **Espace** pour déclencher la transition.

Un écran de chargement s'affiche brièvement puis vous arrivez dans la nouvelle zone. Votre position relative dans la zone de sortie est préservée à l'arrivée.

> **Note :** Un délai de 0,5 s s'applique après l'arrivée pour éviter de déclencher une nouvelle transition par accident.

---

## 6. Les missions

### Choisir une mission

Depuis le menu principal → **Jouer** → la page de **sélection de mission** s'ouvre.

- La liste à gauche affiche les 10 missions disponibles.
- Cliquez sur une mission pour voir son **titre**, sa **date de début**, sa **description** et ses **objectifs**.
- Cliquez sur **Accepter** pour lancer la mission.

### Missions disponibles

| # | Titre | Heure de début | Résumé |
|---|---|---|---|
| 01 | Opération Aube Rouge | 06:00 | Sécuriser la zone industrielle nord infestée de zombies |
| 02 | Extraction Foxtrot | 14:30 | Localiser et évacuer un agent bloqué dans le district est |
| 03 | Dernier Rempart | 22:00 | Renforcer la dernière ligne de défense et protéger les civils |
| 04 | Opération Marteau Gris | 05:30 | Neutraliser les patrouilles et sécuriser une cache d'armement |
| 05 | Nuit Blanche | 23:45 | Infiltration nocturne pour localiser des signaux radio mystérieux |
| 06 | Zone Delta | 12:00 | Reprendre le couloir stratégique Delta aux robots ennemis |
| 07 | Évacuation Bravo | 15:15 | Escorter des civils assiégés dans le secteur Bravo |
| 08 | Protocole Oméga | 20:00 | Récupérer des données classifiées sur des terminaux ennemis |
| 09 | Chasse aux Fantômes | 08:45 | Détruire les brouilleurs de signal des unités fantômes |
| 10 | Forteresse Assiégée | 02:30 | Percer les lignes ennemies et ravitailler le poste Kilo-4 |

> **Astuce débutant :** Commencez par la mission 01 (Opération Aube Rouge), qui débute en plein jour et vous permet de vous familiariser avec les mécaniques de base.

---

## 7. Objets collectables

Deux types d'objets sont éparpillés dans les niveaux :

| Objet | Touche | Effet |
|---|---|---|
| **Ordinateur** | T (à portée) | Incrémente le compteur d'ordinateurs, ajouté à l'inventaire |
| **Robot** (collectable) | T (à portée) | Incrémente le compteur de robots, ajouté à l'inventaire |

### Interagir avec un objet

Approchez-vous d'un objet. Quand vous êtes à portée, le label **"T : Prendre / R : Pousser"** s'affiche sur l'objet.

- **T** — Ramasser l'objet (il disparaît et s'ajoute à votre inventaire).
- **R** — Pousser l'objet dans la direction de votre regard (physique temps réel).

Les positions des objets poussés sont **sauvegardées automatiquement** à la fermeture du menu ou lors d'un changement de zone.

### Notifications

À chaque collecte, un message bref apparaît en haut de l'écran ("Ordinateur collecté !") puis disparaît en 1,5 s.

---

## 8. Les ennemis

### Robots ennemis

Les robots ennemis patrouillent dans les zones. Ils sont identifiables par leur **teinte rouge** et leur **cône de vision rouge** (120° devant eux).

**Comportement :**
- Ils détectent le joueur s'il entre dans leur cône de vision.
- Une fois détecté, ils se déplacent vers vous à 35 px/s.
- Au contact, ils infligent des dégâts en dehors du mode combat (dommages passifs).

**En combat**, leur cône de vision est masqué et les règles du CQB s'appliquent.

### Zombies

Les zombies sont les ennemis narratifs des missions. En termes de gameplay, ils fonctionnent comme des robots ennemis.

---

## 9. Système de combat (CQB)

Le combat se déroule **au tour par tour** avec un système de dés inspiré des JDR classiques.

### Engager le combat

1. Approchez-vous d'un ennemi (à environ 70 px).
2. Appuyez sur **C** pour engager.
3. Un overlay de combat s'affiche au centre de l'écran. Le mouvement est bloqué.

### Statistiques de combat

| Statistique | Valeur initiale | Effet |
|---|---|---|
| Attaque | 10–15 (configurée à la création) | Seuil de réussite du jet d'attaque |
| Défense | 10–15 (configurée à la création) | Seuil de réussite du jet de défense |

> Les ennemis ont aussi une Attaque et une Défense entre 10 et 15, générées aléatoirement.

### Déroulement d'un round

Le combat suit ce schéma, en boucle jusqu'à la mort d'un combattant :

```
1. VOUS ATTAQUEZ
   → Appuyez sur [Espace] pour lancer le dé (1–20)
   → Résultat < votre Attaque = succès → l'ennemi tente de se défendre
   → Résultat ≥ votre Attaque = raté → l'ennemi contre-attaque

2. L'ENNEMI SE DÉFEND (si votre attaque a réussi)
   → Lancer automatique (1–20)
   → Résultat < Défense ennemi = défense réussie, attaque bloquée → l'ennemi attaque
   → Résultat ≥ Défense ennemi = l'ennemi perd 1 PV
       • Si PV ennemi ≤ 0 → ennemi éliminé, combat terminé
       • Sinon → vous contre-attaquez (retour à l'étape 1)

3. L'ENNEMI ATTAQUE (automatique)
   → Résultat < Attaque ennemi = attaque réussie → vous défendez

4. VOUS VOUS DÉFENDEZ (si l'attaque ennemie a réussi)
   → Appuyez sur [Espace] pour lancer le dé (1–20)
   → Résultat < votre Défense = défense réussie → vous contre-attaquez
   → Résultat ≥ votre Défense = vous perdez 1 PV
       • Si PV ≤ 0 → GAME OVER
       • Sinon → l'ennemi attaque à nouveau
```

### Tenter de fuir

Pendant le combat, appuyez à nouveau sur **C** pour tenter de fuir.
- Lancer interne (1–10) : résultat > 5 → fuite réussie, combat terminé.
- Résultat ≤ 5 → fuite ratée → l'ennemi contre-attaque immédiatement.

### Quitter le combat sans résolution

Appuyez sur **Échap** pour quitter le combat immédiatement, sans pénalité ni résolution.

### Game Over

Si vos PV tombent à 0 :
- L'overlay affiche **GAME OVER**.
- Appuyez sur **Espace** → vous pouvez choisir de recommencer.
- Vous serez redirigé vers la création de personnage pour repartir à zéro.

---

## 10. Parler aux PNJ

Les personnages non-joueurs (PNJ) sont repérables à leur **teinte verte** et au nom affiché au-dessus d'eux.

### Ouvrir un dialogue

1. Approchez-vous d'un PNJ jusqu'à voir le label **"Z : Parler"**.
2. Appuyez sur **Z** (ou utilisez le menu radial → Z).
3. La boîte de dialogue s'ouvre en bas de l'écran.

### Navigation dans le dialogue

- Lisez le texte affiché.
- Cliquez sur un **choix** pour orienter la conversation.
- Le dialogue se termine quand il n'y a plus de suite (choix → `null`).

Le mouvement est bloqué pendant un dialogue actif.

> **Exemple :** Dans la zone 1, le **Commandant Dubois** vous donne des renseignements sur la position des zombies et l'emplacement de la base.

---

## 11. Piloter un Mecha

Des Mechas (robots de combat géants) sont présents dans certains niveaux.

### Monter dans un Mecha

1. Approchez-vous du Mecha jusqu'à voir le label **"M : Piloter"**.
2. Appuyez sur **M** pour monter.
   - Votre sprite de joueur est masqué.
   - La caméra zoome légèrement en arrière (×0,8).

### Déplacement du Mecha

Les commandes de déplacement restent les mêmes (Flèches / WASD). Le Mecha se déplace avec **inertie** : il accélère et décélère progressivement.

Le Mecha est plus lent que le joueur à pied mais possède une **hitbox plus grande** et offre une protection accrue.

### Descendre du Mecha

1. Appuyez à nouveau sur **M**.
2. Le jeu calcule automatiquement une **position de sortie sûre** (hors des murs).
3. Votre sprite réapparaît et la caméra revient au zoom normal.

> **Note :** Un court délai s'applique avant de pouvoir remonter dans le Mecha après en être sorti.

---

## 12. Fiche de personnage

La fiche de personnage regroupe toutes les informations de votre mercenaire.

**Ouvrir la fiche :**
- Cliquez sur le bouton **Fiche** dans la barre du HUD.
- Ou appuyez sur **P**.

La fiche comporte trois onglets :

### Onglet Statistiques

| Information | Description |
|---|---|
| Pseudo | Surnom choisi à la création |
| Santé | Points de vie actuels |
| Attaque | Valeur d'attaque au combat |
| Défense | Valeur de défense au combat |
| Grade | Grade militaire |
| Spécialisation | Rôle choisi |
| Crédits | Solde disponible (en ¤) |

### Onglet Inventaire

Liste de tous les objets collectés (ordinateurs, robots). Chaque entrée affiche le type et le nom de l'objet.

### Onglet Équipements

Liste de tous les équipements achetés à l'armurerie.

- **Survolez** un équipement avec la souris pour afficher sa description.
- **Cliquez** sur un équipement pour afficher sa **fiche de détail complète** (toutes les statistiques).

---

## 13. Armurerie

L'armurerie vous permet d'acheter et de vendre des équipements avec vos **crédits (¤)**.

**Ouvrir l'armurerie :**
- Cliquez sur le bouton **Armurerie** dans la barre du HUD.

### Navigation

La colonne de gauche présente quatre catégories :

| Catégorie | Contenu |
|---|---|
| **Armes** | Pistolets, fusils, armes de corps-à-corps, etc. |
| **Protections** | Gilets, casques, boucliers balistiques |
| **Matériels** | Gadgets (vision nocturne, fumigènes, trousses médicales…) |
| **Vêtements** | Tenues tactiques, camouflages, uniformes |

Cliquez sur une catégorie puis sur un article pour afficher sa fiche de détail à droite.

### Acheter un équipement

1. Sélectionnez un article.
2. Vérifiez son prix dans la fiche de détail.
3. Si vous avez suffisamment de crédits, cliquez sur **Acheter (X ¤)**.
4. Les crédits sont déduits et l'objet apparaît dans votre onglet Équipements.

> Si vous n'avez pas assez de crédits, le bouton est désactivé.
> Si vous possédez déjà l'objet, le bouton affiche "Déjà possédé".

### Vendre un équipement

1. Sélectionnez un article que vous possédez déjà.
2. Cliquez sur **Vendre (X ¤)** pour récupérer son prix d'achat.
3. L'article est retiré de votre inventaire et les crédits sont recrédités.

### Crédits de départ

Vous démarrez avec **1 000 ¤**. Gérez votre budget avec soin — certains équipements coûtent cher !

---

## 14. Cycle jour / nuit

Chaque mission se déroule à une heure de jeu précise et le soleil évolue en temps réel.

- Le monde s'assombrit progressivement à l'approche du coucher du soleil.
- La nuit est représentée par un **overlay bleu nuit semi-transparent** sur l'écran.
- L'aube ramène progressivement la luminosité normale.

Les heures de lever et coucher du soleil varient selon la mission. Certaines missions commencent de nuit — équipez-vous en conséquence (gadgets de vision nocturne disponibles à l'armurerie).

> **L'horloge se met en pause** lorsque vous ouvrez un menu (Fiche, Paramètres, Accueil, menu radial).

---

## 15. Menus et paramètres

### Menu principal

Accessible via le bouton **Accueil** du HUD ou la touche **M** en jeu.

| Option | Description |
|---|---|
| Retour au jeu | Reprend la partie sans recharger (disponible en cours de partie) |
| Jouer | Accède à la sélection de mission |
| Paramètres | Ouvre les paramètres |
| Aide | Affiche la liste des contrôles |
| Quitter | Demande confirmation, affiche les crédits puis ferme le jeu |

### Paramètres — Audio

- **Musique** : activer / désactiver la musique de fond.
- **Volume** : slider de 0 à 100.
- **Effets sonores** : activer / désactiver les bruits de pas et effets.
- **Volume effets** : slider de 0 à 100.

### Paramètres — Contrôles

Tableau complet de toutes les touches du jeu.

### Paramètres — Réseau

Paramètres réseau (multijoueur, non actif en solo).

### Paramètres — Compatibilité

Options de compatibilité pour votre matériel.

### Paramètres — Debug

- **Afficher le cône et la flèche** : active ou masque les indicateurs visuels (cône de vision vert + flèche de direction orange) sur votre personnage.

### Réinitialiser

Réinitialise toutes les sauvegardes depuis les fichiers par défaut. Vous serez renvoyé vers la **création de personnage**.

> **Attention :** Cette action efface votre progression (position, inventaire, équipements, crédits).

---

## 16. Sauvegarde et réinitialisation

### Sauvegarde automatique

La partie est sauvegardée automatiquement dans les situations suivantes :

- À la **fermeture du menu** (bouton Accueil).
- Lors d'un **changement de zone** (transition entre niveaux).
- Lors d'un **achat ou d'une vente** à l'armurerie.
- À la **confirmation de quitter** le jeu.

Il n'y a pas de sauvegarde manuelle : tout est géré en arrière-plan.

### Charger la partie

Depuis le menu principal → **Jouer** → sélectionnez une mission → **Accepter**. Votre sauvegarde est chargée automatiquement avant de lancer la mission.

### Réinitialiser la progression

Menu principal → **Paramètres** → **Réinitialiser** (disponible sur la plateforme Linux).

---

## 17. Conseils pour débuter

### Conseils généraux

- **Explorez prudemment** : les ennemis ont un cône de vision. Contournez-les par les flancs pour éviter d'être repéré.
- **Gardez un œil sur votre santé** : si vous tombez à 0 PV, c'est Game Over. Achetez un kit médical à l'armurerie dès que possible.
- **Parlez aux PNJ** : ils donnent des informations précieuses sur la carte et les objectifs.
- **Gérez vos crédits** : vous démarrez avec 1 000 ¤. Priorité aux équipements qui améliorent la survie (protections, soins).

### Conseils de combat

- **Investissez dans la Défense** à la création : bloquer les attaques ennemies est aussi important qu'attaquer.
- **Appuyez sur Espace au bon moment** : prenez le temps de lire le message avant de lancer le dé.
- **Utilisez la fuite (C)** si vous êtes en mauvaise posture — 50 % de réussite, c'est mieux que perdre le dernier PV.
- **Évitez le contact passif** : les ennemis infligent des dégâts au contact même hors combat. Engagez le CQB (C) plutôt que de vous laisser toucher sans réagir.

### Conseils de déplacement

- **Alignez corps et regard** pour vous déplacer à pleine vitesse (70 px/s).
- **Poussez les objets (R)** pour dégager des passages ou créer des couvertures.
- **Attendez le bon angle** avant une transition de zone (le rectangle orange doit être entièrement sous votre personnage).

### Conseils sur l'armurerie

- **Commencez par les protections** : réduire les dégâts reçus allonge considérablement votre survie.
- **Comparez les pénalités de mobilité** : une armure lourde vous ralentit et compromet les retraites.
- **Les gadgets sont situationnels** : un kit de vision nocturne est inutile en plein jour mais indispensable pour les missions nocturnes (03, 05, 10).

### Indicateurs visuels

| Couleur | Signification |
|---|---|
| Cône **vert** | Champ de vision du joueur |
| Flèche **orange** | Direction du corps du joueur |
| Cône **rouge** | Champ de vision d'un ennemi |
| Rectangle **orange** | Zone de transition vers un autre secteur |
| Carré **bleu** | Point de spawn (réapparition) |

---

*Manuel rédigé pour Commando Zombi RPG v4 — Le Sanglier des Ardennes*
*samuel.gondouin@gmail.com*
