# Stasse Rinaldis

Navigateur de cartes Clash Royale pour iPhone et iPad, avec un widget d'écran d'accueil et une app Apple Watch autonome. Les données de cartes proviennent du catalogue public [RoyaleAPI](https://royaleapi.github.io/cr-api-data/).

## Fonctionnalités

- **Liste des cartes** avec recherche, filtre par rareté (Commune → Champion) et tri par nom, élixir ou rareté.
- **Favoris** : marquez vos cartes préférées, elles sont conservées localement (`UserDefaults`).
- **Fiche détaillée** de chaque carte (niveau max, coût en élixir, évolutions, image).
- **Arènes** : liste et détail des arènes du jeu.
- **Statistiques** : nombre total de cartes, élixir moyen, répartition par rareté et par type.
- **Connexion** via Firebase : e-mail / mot de passe ou Google Sign-In.
- **Widget « Card of the Day »** : une carte mise en avant chaque jour sur l'écran d'accueil.
- **App Apple Watch** autonome et en lecture seule, qui charge le catalogue elle-même (pas de dépendance à la synchronisation iPhone → Watch).

## Structure du projet

```
.
├── stasse_rinaldis.xcodeproj   Projet Xcode (à ouvrir)
├── stasse_rinaldis/            App iPhone/iPad
│   ├── Auth/                   AuthManager, AuthView, AccountView, FirebaseSetup
│   ├── Models/                 Card, Arena
│   ├── ViewModels/             CardViewModel
│   ├── Views/                  Listes, détails, arènes et statistiques
│   └── Assets.xcassets/        Icône de l'app et couleurs
├── stasse_rinaldisShared/      Modèle du catalogue et service de récupération (widget + Watch)
├── stasse_rinaldisWidget/      Extension WidgetKit « Card of the Day »
├── stasse_rinaldisWatch/       App Watch autonome, en lecture seule
├── stasse_rinaldisTests/       Tests unitaires (filtres, carte du jour)
├── stasse_rinaldisUITests/     Tests d'interface
└── docs/                       Illustrations sources et autres fichiers hors build
```

## Prérequis

- Xcode 16.4 ou ultérieur
- iOS 18.5+ (app et widget), watchOS 10+ (app Watch)

## Compiler et lancer

1. Ouvrez `stasse_rinaldis.xcodeproj`.
2. Sélectionnez le scheme `stasse_rinaldis` et un simulateur iPhone.
3. Lancez avec **Cmd+R**.

## Authentification (Firebase)

L'app demande une connexion avant d'afficher les cartes. Deux modes, tous les deux gratuits (offre Spark de Firebase) :

- e-mail / mot de passe (inscription, connexion, mot de passe oublié, déconnexion) ;
- Google Sign-In.

Sign in with Apple n'est pas inclus : il exige l'Apple Developer Program payant.

Le code se trouve dans `stasse_rinaldis/Auth/` (`AuthManager`, `AuthView`, `AccountView`, `FirebaseSetup`). Les packages `FirebaseCore`, `FirebaseAuth`, `GoogleSignIn` et `GoogleSignInSwift` sont déjà déclarés dans le projet (Swift Package Manager), ainsi que le flag `-ObjC`.

### Configuration (une seule fois)

1. Sur <https://console.firebase.google.com>, créez un projet (inutile d'activer Google Analytics).
2. Ajoutez une app iOS avec le Bundle ID `com.dev.test.app.stasse-rinaldis`.
3. Dans **Authentication → Sign-in method**, activez **E-mail/Mot de passe** puis **Google**.
4. Téléchargez `GoogleService-Info.plist` **après** avoir activé Google, et glissez-le dans le dossier `stasse_rinaldis/` dans Xcode (target `stasse_rinaldis` cochée). Le nom doit être exactement `GoogleService-Info.plist`.
5. Dans Xcode : target `stasse_rinaldis` → **Info** → **URL Types** → **+**, et collez dans **URL Schemes** la valeur `REVERSED_CLIENT_ID` du plist (elle commence par `com.googleusercontent.apps.`).
6. **Product → Clean Build Folder**, puis lancez l'app.

Sans le plist, l'app ne plante pas : l'écran de connexion affiche un message demandant de l'ajouter. Les tests UI (`-ui-testing`) contournent la connexion.

## Tests

- `stasse_rinaldisTests` (unitaires) : cartes et filtres, carte du jour, modèle de l'Apple Watch (`WatchCatalogModelTests`), logique du widget (`FeaturedCardLoaderTests`) et connexion Firebase (`AuthManagerTests`). Aucun test n'utilise le réseau.
- `stasse_rinaldisUITests` (interface) : navigation dans l'app (lancée avec `-ui-testing`, sans écran de connexion) et écran de connexion (`AuthUITests`, lancé avec `-ui-testing-auth`, sans Firebase ni vrai compte).

Lancez tous les tests avec **Cmd+U**, ou en ligne de commande :

```bash
xcodebuild test -project stasse_rinaldis.xcodeproj -scheme stasse_rinaldis \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Si le simulateur signale « Invalid placeholder attributes », nettoyez le dossier de build (**Shift+Cmd+K**), supprimez l'app du simulateur et relancez.
