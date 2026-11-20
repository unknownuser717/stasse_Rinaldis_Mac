The project includes:
- `stasse_rinaldis`: the iPhone/iPad app.
- `stasse_rinaldisWidget`: the WidgetKit "Card of the Day" extension.
- `stasse_rinaldisWatch`: a standalone, read-only Watch app for cards and stats.
- `stasse_rinaldisShared`: the public card catalog model and fetch service used by the widget and Watch app.
- `stasse_rinaldisTests`: unit tests for filtering and daily card selection.
- `stasse_rinaldisUITests`: an app navigation smoke test.

The widget and Watch app load the public RoyaleAPI card catalog independently; they do not depend on iPhone-to-Watch synchronization.