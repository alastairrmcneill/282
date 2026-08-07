## Architecture

- **State**: `provider` package, `ChangeNotifier` classes named `<Feature>State` (e.g. `FeedState`). Private fields (`_globalPosts`), public getters, and setter-style methods (`set setGlobalStatus(...)`) that mutate then call `notifyListeners()`. Async loaders catch errors, log via `Logger`, and set an `Error` object on state rather than throwing.
- **Repos**: one class per data source in `lib/repos/`, named `<Thing>Repository`. Thin wrapper around Supabase (`SupabaseClient`) or Firebase — no business logic, just queries. Injected via constructor (`Provider(create: (_) => XRepository(client))` in `app_providers.dart`).
- **Screens**: each feature gets a folder under `lib/screens/<feature>/` with subfolders as needed:
  - `screens/` — full-page `Scaffold` widgets
  - `state/` — `ChangeNotifier`s for that feature
  - `widgets/` — feature-local widgets
  - `helpers/` — pure logic/navigation helpers
  - a `widgets.dart` (and `screens.dart` where present) barrel file exporting everything in that folder
- Shared, cross-feature widgets go in `lib/widgets/` (also barrel-exported via `widgets.dart`).
- Top-level barrels exist per layer: `models/models.dart`, `repos/repos.dart`, `screens/notifiers.dart`, `extensions/extensions.dart`, `analytics/analytics.dart`, `logging/logging.dart`. Import the barrel, not individual files, from outside that folder.

## Widgets

- **One widget per file.** File name matches the class name in snake_case.
- Prefer `StatelessWidget` and small, composable widgets over large `build()` methods. If a `build()` method needs a sub-section (a header, a row, a card), extract it into its own widget file rather than a private `_buildX()` method.
- Keep widgets small and single-purpose — a widget file should describe one UI element, not a whole screen section with many concerns.
- Constructor params: `final` fields, `const` constructor with `super.key` first, `required` named params.

## Styling — always go through the theme

- Never hardcode colors, font sizes, or weights in a widget. Use:
  - `context.colors.xxx` (from `AppColorsExtension`) for any color — `background`, `surface`, `accent`, `textPrimary`, `textSubtitle`, `textMuted`, `border`, `divider`, etc. Colors are defined once in `lib/support/theme.dart` (`MyLightColors` / `MyDarkColors`) so light/dark mode stay consistent automatically.
  - `Theme.of(context).textTheme.xxx` for text styles (`headlineMedium`, `titleMedium`, `bodyLarge`, etc., defined in `textTheme` in `theme.dart`). Use `.copyWith(color: context.colors.textMuted)` etc. rather than a one-off `TextStyle`.
  - Button/card/input styling comes from the `ThemeData` component themes (`elevatedButtonTheme`, `cardTheme`, `inputDecorationTheme`, ...) — don't restyle a `Card`/`ElevatedButton`/`TextField` inline unless it's a genuinely one-off case.
- If a new color or text style is needed, add it to `theme.dart` (both light and dark) rather than inlining it in a widget.
- Icons: `phosphor_flutter` (`PhosphorIconsBold`/`PhosphorIconsRegular`) is the default icon set in newer code.

## Comments

- Don't add comments explaining what a line does, and don't add a comment for every change/edit.
- Only comment where logic is genuinely non-obvious (e.g. "keyset cursor = last post currently shown", "Not logged in"). One short line, not a paragraph.
- No changelog-style or narrating comments (`// added this to fix X`, `// updated for feature Y`).

## Other conventions

- Barrel exports (`export 'x.dart';`) are added whenever a new file is added to a folder that has one.
- Repo/state constructors take dependencies positionally, undecorated (no DI framework beyond `provider`).
- Error handling in state classes: `try/catch`, log with the injected `Logger`, set a user-facing `Error(message: ...)` — don't let exceptions bubble up to the UI.
- Analytics events go through the injected `Analytics` class with `AnalyticsEvent`/`AnalyticsProp` enums, not raw strings.
- Run `flutter analyze` after changes; don't drive the iOS Simulator — let the user verify UI changes manually.
