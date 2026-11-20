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

## Tests

Run all tests with **Cmd+U**, or from the terminal:

```
xcodebuild test -project stasse_rinaldis.xcodeproj -scheme stasse_rinaldis \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

If the simulator reports "Invalid placeholder attributes", clean the build folder (**Shift+Cmd+K**), delete the app from the simulator and run again.
