# Stasse Rinaldis

A Clash Royale card browser for iPhone and iPad, with a home-screen widget and a standalone Apple Watch app. Card data comes from the public RoyaleAPI catalog.

## Project structure

```
.
├── stasse_rinaldis.xcodeproj   Xcode project (open this)
├── stasse_rinaldis/            iPhone/iPad app
│   ├── Models/                 Card, Arena
│   ├── ViewModels/             CardViewModel
│   ├── Views/                  List, detail, arena and stats screens
│   └── Assets.xcassets/        App icon and colors
├── stasse_rinaldisShared/      Card catalog model and fetch service (widget + Watch)
├── stasse_rinaldisWidget/      WidgetKit "Card of the Day" extension
├── stasse_rinaldisWatch/       Standalone, read-only Watch app
├── stasse_rinaldisTests/       Unit tests (filtering, daily card selection)
├── stasse_rinaldisUITests/     UI navigation tests
└── docs/                       Source artwork and other non-build files
```

The widget and the Watch app load the card catalog on their own; they do not depend on iPhone-to-Watch synchronization.

## Requirements

- Xcode 16.4 or later
- iOS 18.5+ (app and widget), watchOS 10+ (Watch app)

## Build and run

1. Open `stasse_rinaldis.xcodeproj`.
2. Select the `stasse_rinaldis` scheme and an iPhone simulator.
3. Run with **Cmd+R**.

## Authentification (Firebase)

L'app demande une connexion avant d'afficher les cartes. Deux modes, tous les deux gratuits (offre Spark de Firebase) :

- email / mot de passe (inscription, connexion, mot de passe oublié, déconnexion) ;
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

Run all tests with **Cmd+U**, or from the terminal:

```
xcodebuild test -project stasse_rinaldis.xcodeproj -scheme stasse_rinaldis \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

If the simulator reports "Invalid placeholder attributes", clean the build folder (**Shift+Cmd+K**), delete the app from the simulator and run again.
