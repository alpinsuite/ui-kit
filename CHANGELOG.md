# Changelog

All notable changes to this package are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-08-08

### Added

- **24 glyphs on `SlateIcons`**, taking the set from 23 to 47. Drawn for
  [AlpinSuite/pdf-ninja](https://github.com/AlpinSuite/pdf-ninja), the kit's
  second consumer, but none of them knows what a PDF is — they are the
  vocabulary any document-shaped desktop tool needs, and the set had visible
  gaps without them (`chevronLeft` had no partner to its three siblings).
  - Navigation: `chevronLeft`, `arrowLeft`, `arrowRight`, `undo`, `redo`.
  - Zoom: `zoomIn`, `zoomOut`, built on `search`'s magnifier so the three read
    as one family.
  - Panels: `sidebar`, `tiles`, `list`.
  - Documents: `file`, `folder`, `save`, `print`, `trash`, `rotateLeft`,
    `rotateRight`.
  - State and editing: `lock`, `info`, `pencil`, `layers`, `eye`, `signature`,
    `textCursor`.

  A visual change is an API change, so this is a minor bump rather than a patch.

- **`SlateField.obscureText`**, which also turns off the platform's suggestion
  and autofill machinery. A password field that hides its characters while
  offering to remember them is worse than one that does neither, so the two are
  one flag rather than three.

  Note that the thumbnail-grid glyph is `tiles`, not `grid`: `SlateIcons.grid`
  is the 16-unit authoring grid every glyph is drawn against, and the two cannot
  both have the name.

## [0.1.0] - 2026-08-07

First release. The kit was extracted unchanged from
[rbuache/paint](https://github.com/rbuache/paint), where it lived as
`lib/slate/` and was written from the start to be lifted out into its own
package.

### Added

- **`SlatePalette`** — every colour by the role a dense desktop interface
  actually has: chrome, panel, popover, border, separator, ink, field. Dark and
  light constants, and `copyWith` for recolouring the accent.
- **`SlateMetrics`** — every size, with an explicit height on each control, and
  `scaled()` for a denser or roomier build of the same design.
- **`SlateThemeData` / `SlateTheme`** — the two above plus a font, the inherited
  widget that carries them, and `toMaterialTheme()` so Scaffold, Navigator,
  dialogs and text selection do not arrive in a different palette.
- **`SlateIcons` / `SlateIcon`** — 23 glyphs drawn as paths on a 16-unit grid.
  No font, no asset; each takes its colour and stroke weight from the caller.
- **`SlateMenuBar` / `SlateMenuButton` / `SlateMenuItem` / `SlateSubmenu` /
  `SlateMenuSeparator`** — an application menu that switches on hover once one
  of its menus is open, with submenus, checked rows and shortcut labels.
- **`SlateSelect`** — a value picker that reads as text until you reach for it.
- **`SlateButton` / `SlateIconButton` / `SlateCheckbox` / `SlateSegmented` /
  `SlateSlider` / `SlateField` / `SlateSeparator`** — the controls a toolbar and
  a dialog need.
- **`SlateDialog` / `SlateLabeledField`** — a dialog drawn as a popover rather
  than a Material card.
- **A gallery** under `example/`, showing every widget in both palettes.
- **Tests.** The kit had none inside paint; it now has 95 covering the palette,
  the metrics, the theme, every control, the menu's hover-switching and
  close-the-whole-chain behaviour, the select, the dialog and every glyph.
- **`tools/check_kit_purity.sh`**, run by CI, which fails if the kit gains an
  import outside Flutter, a runtime dependency beyond Flutter, or a source file
  the entrypoint does not export exactly once. That the kit never reached back
  into an application is what made this extraction possible in one piece, and
  nothing but this check keeps it true.
