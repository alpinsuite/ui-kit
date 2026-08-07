# Slate

A compact Flutter widget kit for desktop tools, in the visual language editors
and IDEs converged on: flat surfaces, hairline rules instead of elevation, dense
rows, one restrained accent, and controls that reveal their affordance when you
reach for them rather than shouting it at rest.

It holds nothing application-specific — no controllers, no models, no
localisations, no domain concepts. Every widget takes the strings it displays as
parameters, so the caller owns translation. `tools/check_kit_purity.sh` enforces
that on every CI run rather than leaving it to a rule in a file.

## Installing

The package is not on pub.dev. Depend on a tag:

```yaml
dependencies:
  slate_ui:
    git:
      url: https://github.com/alpinsuite/ui-kit.git
      ref: v0.1.0
```

Pin a tag rather than a branch. `ref: main` re-resolves whenever `main` moves,
which turns an unrelated `pub get` into an unannounced upgrade.

## Using it

Install the theme once, above everything that draws:

```dart
const slate = SlateThemeData.dark();   // or .light()

MaterialApp(
  theme: slate.toMaterialTheme(),
  builder: (context, child) => SlateTheme(data: slate, child: child!),
  home: const MyWindow(),
);
```

`toMaterialTheme()` exists because an app still gets Scaffold, Navigator,
dialogs and text selection from Material, and those must not arrive in a
different palette than the kit's own widgets.

Then read the theme wherever you need it:

```dart
final theme = context.slate;          // SlateThemeData
final palette = context.slateColors;  // SlatePalette
final metrics = context.slateMetrics; // SlateMetrics
```

Run `example/` to see all of it:

```bash
cd example && flutter run -d linux
```

## What is in it

| | |
|---|---|
| `SlatePalette` | Every colour, by the role a dense desktop interface actually has: chrome, panel, popover, border, separator, ink, field |
| `SlateMetrics` | Every size. Each control carries an explicit height |
| `SlateThemeData` / `SlateTheme` | The two above plus a font, and the inherited widget that carries them |
| `SlateIcons` / `SlateIcon` | A thin icon set drawn as paths on a 16-unit grid — no font, no asset, takes its colour from the caller |
| `SlateMenuBar` / `SlateMenuButton` / `SlateMenuItem` / `SlateSubmenu` / `SlateMenuSeparator` | An application menu that switches on hover the way a menu bar should |
| `SlateSelect` | A value picker that reads as text until you reach for it |
| `SlateButton` / `SlateIconButton` / `SlateCheckbox` / `SlateSegmented` / `SlateSlider` / `SlateField` / `SlateSeparator` | The controls a toolbar and a dialog need |
| `SlateDialog` / `SlateLabeledField` | A dialog drawn as a popover rather than a Material card |

## Two decisions worth knowing about

**The select has no box at rest.** A bordered, filled control is a heavy shape
sitting next to whatever label introduces it, and in a dense options row that
weight is what makes an interface look bulky even when the type is the right
size. The border and fill arrive on hover, where they are actually needed.

**Menu rows are plain widgets, not `MenuItemButton`s.** That is what lets them
be drawn exactly as designed. The cost is that closing the menu becomes their
own job, which `SlateMenuScope` handles — note that it is installed *above* the
`MenuAnchor`, because the panel is an overlay child and inherits only from the
anchor's ancestors. Putting the scope inside the anchor's `builder` compiles
fine and silently does nothing.

## Icons

Add one as a static method on `SlateIcons` that paints into a 16×16 box with the
`Paint` it is handed:

```dart
static void arrowRight(Canvas canvas, Paint stroke) {
  canvas
    ..drawLine(const Offset(3, 8), const Offset(13, 8), stroke)
    ..drawPath(
      Path()
        ..moveTo(9, 4)
        ..lineTo(13, 8)
        ..lineTo(9, 12),
      stroke,
    );
}
```

Keeping every glyph on one grid with one stroke weight is most of what makes an
editor interface feel like a single piece of software, so match the existing
ones rather than tracing something from elsewhere. Add it to the map in
`example/lib/main.dart` and to `test/slate_icons_test.dart` in the same change.

## Theming

`SlatePalette` is a plain value class rather than a Material `ColorScheme`: the
roles are the ones a dense desktop interface actually has, and mapping them onto
Material's semantic slots loses exactly the distinctions the design depends on.

Recolour without rebuilding the palette:

```dart
const theme = SlateThemeData(
  palette: SlatePalette.dark,
  metrics: SlateMetrics.standard,
);

final blue = SlateThemeData(
  palette: SlatePalette.dark.copyWith(accent: const Color(0xFF3B82F6)),
);
```

`SlateMetrics.scaled(1.25)` gives a roomier build of the same design. It leaves
the corner radii alone on purpose — a radius is a constant of the visual
language, not a size, and scaling it produces a differently-shaped interface
rather than a bigger one.

## Versioning

[Semantic Versioning](https://semver.org), with `pubspec.yaml` as the single
source of truth. Below 1.0.0 the API may still change between minor versions.
See [docs/RELEASING.md](docs/RELEASING.md).

## Development

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
bash tools/check_kit_purity.sh
flutter test

cd example && flutter test && flutter build linux --release
```

Those five are exactly what the CI analyze job runs, so a green local run means
that job is green.

## Licence

MIT. See [LICENSE](LICENSE).
