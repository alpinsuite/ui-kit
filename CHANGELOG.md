# Changelog

All notable changes to this package are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2026-08-08

### Added

- **Media transport glyphs: `play`, `pause`, `volume` and `volumeOff`.**
  Kino needs them for its transport bar, and no application should be drawing
  its own — a set that is uniform everywhere except the one control the user
  looks at most is not a uniform set.

  `play` and `pause` are filled rather than stroked, and are the only glyphs
  here that are. A transport control is read at a glance, often at the edge of
  vision while something else holds the attention, and a hairline triangle does
  not survive that.

  `volume` and `volumeOff` share their speaker cone through one private helper
  so the pair cannot drift apart. `volumeOff` strikes through with a cross
  rather than a slash: at sixteen pixels a slash reads as one more wave, which
  is the opposite of what it means.
## [0.5.1] - 2026-08-08

### Fixed

- **Clicks landed only where a child happened to paint.** Every
  `GestureDetector` in the kit but two used the default `deferToChild`, so a
  control was only as clickable as its contents. `SlateActivityBar` was the
  worst of them: the button is a bare `SizedBox` around a `Stack`, whose only
  hit-testable child is the glyph, so a destination ignored every click except
  one within a few pixels of its centre. The rail read as unresponsive, and
  the natural response — clicking again, harder, slightly differently — is
  what eventually worked.

  All of them now set `HitTestBehavior.opaque`, which is what the data grid and
  the split divider already did. A control's target is now its whole box, in
  the activity bar, the tabs, the status bar, the tree row, the menu rows, the
  select and every control in `slate_controls`.

  Found by using pdf-ninja rather than by testing it, which is its own lesson:
  a widget test taps `find.byType(...)`, and `tester.tap` aims at the centre —
  the one point that worked.

## [0.5.0] - 2026-08-08

### Added

- **`SlateGridController.vertical` and `.revealRow`.** A grid driven from the
  keyboard has to keep the focused row on screen: a cursor that moves out of
  view is a cursor the user has lost, and they will press the arrow again.

  `revealRow` scrolls the *least* distance that makes the row visible rather
  than centring it. Centring on every arrow press makes the whole grid lurch
  and takes away the surrounding rows the user was reading. It is also safe to
  call before the grid has been laid out, which is what restoring a saved
  cursor does.

## [0.4.0] - 2026-08-08

### Added

- **`SlateActivityItem.enabled`** and **`SlateTab.leading`**, both added for
  [AlpinSuite/pdf-ninja](https://github.com/AlpinSuite/pdf-ninja) and both
  general.

  A disabled activity item is dimmed and stays in the rail rather than being
  dropped from it: a rail whose destinations come and go teaches the user that
  the missing ones do not exist, and shifts the ones that remain out from under
  the pointer already aimed at them. It is still announced to a screen reader,
  as disabled.

  `SlateTab.leading` is a glyph before the label for a state the label cannot
  carry — locked, read-only, in error. Deliberately a `SlateIconDraw` and not a
  widget: a tab is a dense row with a fixed height, and an arbitrary child is
  how one tab ends up taller than its neighbours.

- **`SlateTreeRow`** — a row in an outline: disclosure triangle, indent guides
  and the selection and hover states. A leaf gets the indent without the
  triangle rather than a blank where one would be, so the names still line up.

- **`SlateDataGrid`, `SlateGridColumn` and `SlateGridController`** — the grid
  primitives: a header row with draggable column edges, a body that scrolls
  horizontally under it in lockstep, and virtualised rows.

  Virtualised from the first version rather than as a later optimisation: a
  grid that builds every row is a grid that has to be rewritten the first time
  somebody opens a real document, and by then something else depends on the way
  it was written.

  The grid holds no data. It is told a row count and asked for a cell, which is
  what keeps it from knowing whether it is showing tasks, pages or resources.

  A visual change is an API change, so this is a minor bump rather than a patch.

### Fixed

- **`SlateActivityBar` overflowed instead of scrolling** when the window was
  shorter than its own destinations. Unusual but reachable — a laptop in a
  split workspace gets there — and the failure mode was the worst available: the
  last destinations fall off the bottom with no way to reach them. The rail now
  scrolls and the footer stays pinned.

## [0.3.0] - 2026-08-08

### Added

- **The window shell.** Five widgets that every desktop tool in the suite needs
  and none of which knows what an application is: what they switch to, what a
  tab holds and what a status segment counts are all the caller's business.
  - **`SlateActivityBar`** and **`SlateActivityItem`** — the icon rail. Reports
    an index; marks the current destination with an accent rule down its
    leading edge. Secondary destinations pin to the bottom and are indexed
    separately, because they are a different list rather than a continuation of
    the first. `SlateActivityItem.badge` is a `String`, not an `int`, so the
    caller owns what "more than ninety-nine" looks like in their language.
  - **`SlateSplitView`** — a draggable divider with a minimum extent for each
    pane. The position is a *fraction of the space the panes share*, so a
    persisted layout survives a resize, and both minimums are honoured exactly
    rather than to within the divider's own width. Pass `fraction` to drive it
    from outside; `onFractionChanged` fires continuously so a caller that
    persists the layout can debounce.
  - **`SlateSidePanel`** — a titled panel with a slot for header actions.
  - **`SlateTabStrip`** and **`SlateTab`** — document tabs that scroll rather
    than collapsing into a menu, because a tab that has silently vanished is
    worse than one you have to scroll to. The modified dot becomes the close
    button on hover, so the two never compete for the same corner.
  - **`SlateStatusBar`** and **`SlateStatusItem`** — bottom segments, clickable
    when given a handler. A count of problems that jumps to the problems is
    worth having; a count that just sits there is not.

- **13 glyphs on `SlateIcons`**, taking the set from 47 to 60: `calendar`,
  `gantt`, `milestone`, `resource`, `baseline`, `warning`, `report`,
  `settings`, `link`, `filter`, `indentIncrease`, `indentDecrease`,
  `criticalPath`. Drawn for
  [AlpinSuite/fluid-plan](https://github.com/AlpinSuite/fluid-plan), but none
  of them knows what a project plan is — they are the vocabulary any tool that
  shows work over time needs.

- **`SlateMetrics.activityBarWidth`, `.tabHeight` and `.splitterHitExtent`.**
  The last is the width of a split divider *to the pointer*: the divider is
  drawn as a hairline because a visible bar between two panes is noise, and a
  hairline is impossible to hit. It is deliberately not scaled by
  `SlateMetrics.scaled`, because a pointer does not get smaller when the
  interface gets denser.

  A visual change is an API change, so this is a minor bump rather than a patch.

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
