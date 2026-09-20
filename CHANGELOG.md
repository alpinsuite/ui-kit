# Changelog

All notable changes to this package are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the package uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.10.0] - 2026-09-20

### Changed

- **Relicensed to Apache-2.0** from MIT. Still permissive: use it, change it,
  ship it inside a proprietary product. What Apache adds over MIT is an
  explicit patent grant with defensive termination, and an explicit statement
  that the licence conveys no rights in the names or marks. Both are what an
  adopter's counsel checks before building a product on a design system.
  Versions up to and including 0.9.0 were published under MIT and stay
  available under it. Apache-2.0 is GPLv3-compatible and GPLv2-incompatible.

## [0.9.0] - 2026-09-17

### Fixed

- **`danger` could not be read as text.** It was chosen as a fill — the close
  button's hover — and applications draw every error message in it. In the dark
  palette it was 3.55:1 to 4.42:1 on the kit's surfaces, under WCAG AA's 4.5 on
  every one of them and 3.88 on a dialog; in the light palette it was 4.12 on a
  hovered row and 4.43 on a panel, passing only on white.

  It is now `0xFFED685E` in the dark palette and `0xFFC53328` in the light: at
  least 4.59:1 and 4.70:1 as text on background, chrome, panel, popover, hover,
  selected and field, while the close button's white glyph keeps 3.11:1 and
  5.41:1 on it. `slate_palette_test.dart` measures every text colour on every
  surface, and the accent as a glyph, so the next palette change is held to
  both.

  **This is a visual change**: the red is lighter in the dark palette and a
  shade darker in the light one.

- **An emphasised `SlateStatusItem` drew its label in the accent**, 4.20:1 on
  the light bar and 3.91 under the pointer. The label is now ink and the icon
  carries the accent, where a glyph needs 3:1 — the choice the chosen segment of
  a `SlateSegmented` made. **This is a visual change**: an emphasised label is
  no longer in the accent colour.

## [0.8.0] - 2026-09-17

### Added

- **`SlateRadioGroup`** — mutually exclusive choices with none of them hidden.
  A `SlateSelect` shows one option and puts the rest behind a click, which is
  right for a long list where the current value is the interesting part, and
  wrong for a small set somebody is being asked to *choose between*: comparing
  four options means reading four options, and a dropdown makes that a click
  and a memory test. Excel's Insert Cells is the shape it exists for.

  A group rather than a widget per button, so exclusivity is structural — radio
  buttons each carrying their own `selected` flag are a set of booleans someone
  has to keep consistent, and the bug is always two of them true at once.
  Individual options can be disabled (`enabledOf`) rather than removed, because
  a choice that vanishes changes the shape of a dialog between two openings of
  it. A value that is not in the list selects nothing rather than throwing,
  which is what a dialog re-opened on a changed document needs.

  Drawn as a ring with a dot, not a filled disc: a radio button filled solid
  like a tick box is one a reader has to look twice at to tell from one.

- **`SlateCheckbox` and `SlateField` can be disabled**, which is the convention
  every other control here already followed — `onChanged: null` on the box,
  `enabled: false` on the field. A tick box that cannot be ticked is a real
  state (an option that only applies to some documents, a setting another
  setting turns off), and the alternative to showing it disabled is hiding it,
  which teaches the reader it does not exist and leaves them hunting for it on
  the next document where it does.

  Both keep showing their value. A disabled ticked box still reads as ticked
  and a disabled field still shows its text: that is the state being reported,
  and blanking it to make a point about being disabled throws away the answer
  the reader will get back when it is enabled again. A disabled box is not a
  tab stop, matching `SlateFocusable`.

- **`SlateSplitButton`** — a default action and a list of alternatives behind a
  chevron. Two targets, not one: pressing the icon does the thing the reader
  almost always wants, and the chevron offers the rest. Paste and Paste Special
  are one gesture and one afterthought, not two equal choices, and a toolbar
  that spends two whole buttons on them says otherwise.

  The halves disable separately, which is what the case actually wants: a paste
  button with an empty clipboard has nothing to paste and still has
  alternatives worth reading. **An empty list draws no chevron at all**, rather
  than a disabled one — the one place this kit's usual rule (disabled rather
  than absent, because a command that vanishes teaches the reader it does not
  exist) does not apply, because a chevron is not a command, it is a claim
  about what is behind it. Drawn disabled it is either `inkDim` and looks live,
  or `border` and all but invisible against `chrome`, which reads as a
  rendering fault.

  Both halves are tab stops, and the chevron's focus node goes to
  `MenuAnchor.childFocusNode` — without it, opening the list from the keyboard
  shuts it again on the way in.

- **35 spreadsheet glyphs**, which is most of a spreadsheet's toolbar:
  `paste` `cut`; `borders` `bordersOutline` `bordersNone`; `fillColor`;
  `cellAlignTop` `cellAlignMiddle` `cellAlignBottom`; `wrapText`;
  `mergeCells` `unmergeCells`; `percent` `currency` `commaStyle`
  `decimalIncrease` `decimalDecrease`; `sigma` `fx`;
  `sortAscending` `sortDescending`; `insertRow` `deleteRow`
  `insertColumn` `deleteColumn`; `freezePanes` `gridlines`; and
  `chartColumn` `chartBar` `chartLine` `chartArea` `chartScatter`
  `chartPie` `chartDoughnut` `chartRadar`.

  Three of them are named for what a spreadsheet means rather than for what
  they look like, and the reasons are worth having. `cellAlign*` rather than
  `alignTop`, because `alignLeft`/`alignCenter`/`alignRight` already own "align
  text" here and mean the other axis. `currency` is the generic currency sign
  `¤` and not a dollar, because the preset it labels takes its symbol from the
  running locale and a button that prints one symbol while applying another is
  worse than an abstract mark. `sortAscending`/`sortDescending` are bars rather
  than A-Z, which would be a Latin alphabet baked into a glyph.

  Eight chart glyphs rather than one generic chart mark, because the place they
  are needed is a gallery offering all eight at once, where the picture is the
  only thing telling them apart.

  Six of these were drawn twice before they were right, and the contact sheet
  is why — `fillColor` as a tipped bucket read as an eraser, a stroked
  `commaStyle` read as a numeral 2, `freezePanes` and `gridlines` were the same
  picture, both `mergeCells` arrowheads were drawn inside out into a diamond,
  and `chartRadar`'s plotted series is three pixels across at a toolbar's size
  and closes into a blot. None of that is visible in the source.

- **`tableHeaderRow`**, for a word processor: a table whose first row is
  filled, which is `w:tblHeader` — the row Word repeats at the top of every
  page a table runs onto. It is the one glyph a table toolbar needs that a
  spreadsheet has no idea of, and it is the fill that carries it: drawn as an
  outline it is `table` again.

- The gallery and the test map now list **the same glyphs**. Six that landed
  with the capture-and-annotation set — `upload` `envelope` `person` `reply`
  `send` `flag` — had never been added to `example/lib/main.dart`, so the one
  place a person can look at the kit was quietly missing them.

### Fixed

- **`SlateButton`, and every segment of a `SlateSegmented`, were smaller than a
  pointer target has to be.** WCAG 2.2's 2.5.8, at level AA, is 24×24. A button
  was twenty-three points high. A segmented control was twenty-four, and held
  segments of twenty-two: its border was part of its decoration, and a
  decoration's border insets the child by its own width.

  `SlateMetrics.buttonHeight` is now 24, the value `fieldHeight` was already
  raised to for the same reason. The segmented control paints its border over
  the segments instead of around them, which looks exactly as it did and gives
  each segment the control's full height.

  **This is a visual change**: every text button in an application is a point
  taller.

- **A chosen segment's label could not be read on its own highlight.** It was
  drawn in the accent, which on the selected fill is 4.00:1 in the light palette
  — under the 4.5 text of this size needs. It is `ink` now, as the ribbon's tabs
  already were, and the fill still says which segment is chosen. The dark
  palette passed at 6.45:1 and changes too, so the two palettes do not disagree
  about what a chosen segment looks like.

  Both found by product_flow's accessibility audit, the first time its PDF
  reader put a row of short text buttons and a segmented control on screen. The
  test for each fails against the code before the fix.

- **`SlateStatusBar` painted the overflow stripe as soon as an application put
  one item too many in it**, which an application will: a status bar is where
  everything ends up. It was a plain `Row` of leading, a `Spacer` and trailing,
  with nothing to give.

  The two halves are not worth the same, so they do not behave the same. The
  **controls keep their size** — they are the half you still have to be able to
  press — and the **read-outs give way**, scrolling sideways in whatever room
  is left. A bar with room to spare is unchanged: the leading group is
  `Flexible` and loose, so it lays out at its natural size and nothing moves.

  Found from express, whose status bar gained a language and a zoom slider on
  the same afternoon and overflowed by 66 pixels in a narrow window.

- **`SlateColorButton` lit both its halves together**, which makes a split
  button look like one wide button and leaves the second target to be found by
  accident. Only the half under the pointer lights now, matching
  `SlateSplitButton` — the two sit side by side on a real toolbar, and two
  split buttons behaving differently reads as a bug in one of them.

- **Every control the keyboard change touched had stopped filling the width its
  parent gave it, and the gap beside it swallowed clicks.** `SlateFocusable`
  wraps its child in a `Stack` to draw the focus ring as an overlay, and a
  `Stack` loosens the constraints it hands its children — so a control that a
  parent had stretched (a `SlateSelect` in a dialog row, a `SlateButton` in an
  `Expanded`) shrank back to its natural size while the box around it still
  took the full width. A click at the centre of where the control had always
  been landed on nothing: dropdowns stopped opening, buttons stopped pressing.
  `StackFit.passthrough` hands the parent's constraints down unchanged.

  **Nothing in this kit's own tests could have caught it**, and that is the
  part worth keeping: every control here is pumped on its own, where its
  natural size *is* the width it is given, so the two are the same number and
  the bug is invisible. It surfaced in an application — a conditional-formatting
  dialog whose colour dropdown would not open. The new test stretches a control
  with `Expanded` and then presses it at its centre, which is the half a size
  assertion alone would still miss.

- `SlateSelect` hands its trigger's focus node to `MenuAnchor.childFocusNode`.
  A menu closes when focus lands outside it, and making the trigger focusable
  put a focus node exactly there — so opening the list from the keyboard would
  shut it again on the way in.

- **A `SlateCheckbox` with a sentence for a label painted an overflow stripe.**
  Its row is `min`-sized so it fits its label, which is right until the label
  is longer than the column it sits in — a settings checkbox in a dialog. The
  label is `Flexible` and ellipsizes now. A stripe is not a design decision
  anyone made; it is what happens when nobody decided.

- **Every control in the kit was invisible to `Tab`.** They were bare
  `GestureDetector`s, so a window built out of them had no keyboard path
  through it at all — the only tab stops an application got were the text
  fields Flutter makes focusable by itself. `SlateButton`, `SlateIconButton`,
  `SlateCheckbox`, `SlateSegmented`, `SlateSelect`, `SlateTabStrip`,
  `SlateStatusItem` and `SlateActivityBar` are now reachable, and `Enter` and
  `Space` both press what the keyboard is on.

  Nothing changes for a mouse. Flutter shows the ring only for keyboard focus,
  so clicking a button does not leave one behind it, which is the thing that
  makes rings look like noise and gets them removed again.

  Four things are still unreachable and are named here rather than left to be
  discovered: `SlateDataGrid` rows, the swatches in `SlateColorField`, the
  items in `SlateMenu` and `SlateContextMenu`, and the drag handles of
  `SlateSplitView` and `SlateScrollbar`. The first two need a roving stop and
  therefore an API decision about who nominates it; the menus need arrow
  navigation inside an overlay, which is a different mechanism from a tab
  stop; a resize handle needs a keyboard gesture, not a press.

- `SlateSegmented` no longer overflows a parent narrower than its labels. It
  still sizes to its content, but each segment can now shrink and its label
  ellipsises, so a control in a side panel truncates instead of showing an
  overflow stripe. Found by a side panel whose options grew by one word.

### Added

- `SlateFocusable`, the wrapper the above is built out of, exported so an
  application can make its own controls reachable the same way. A disabled
  control — `onPressed: null`, as everywhere in this kit — is deliberately not
  a tab stop: landing on something that cannot be activated is a dead end the
  reader has to tab out of.

  The ring is drawn as an overlay inside the control's own bounds rather than
  as a border around it, so it costs no space. A `Container` with a border
  insets its child, which would have made every control in the kit two pixels
  taller than `SlateMetrics` says — permanently, not only while focused.

- `SlateTreeRow.focusable`, off by default. A long outline gets **one** tab
  stop, not one per row: four hundred rows with four hundred stops in them make
  `Tab` useless for reaching anything past the tree, so the caller nominates
  the selected row, or the first when nothing is selected. A short list of
  independent switches marks every row instead — a reader who can reach only
  the first switch can operate only the first switch.

- `SlateActivityBar` is a `FocusTraversalGroup`. Traversal is geometric, and a
  rail down the left edge spans every band the panes beside it occupy, so `Tab`
  went: first destination, the whole toolbar next to it, second destination.
  The group keeps the rail together, and it sorts first because it is leftmost.

- `showSlatePopover`, an overlay anchored to a control that holds whatever the
  caller builds, and resolves to the value its builder's `close` was given. The
  kit had `showSlateContextMenu` for a list of items and nothing general, and a
  colour grid, a filter panel and a date picker are all a small surface attached
  to a control — each one written by hand is another place the shadow, the
  dismissal and the screen-edge behaviour come out slightly different.

  One that would run off the bottom opens above its anchor rather than being
  squashed against the edge: a panel jammed into the last twenty pixels is
  unusable. A tap outside or `Escape` dismisses it, with `null`.

- `SlateIcons.upload`, the mirror of `download` — the same tray with the arrow
  reversed. The pair is only legible as a pair: an upload drawn with a different
  tray reads as a different kind of action.
- Thirteen glyphs for capture and annotation, on the existing 16-unit grid:
  `cursor`, `regionSelect`, `monitor`, `camera`, `timer`, `crop`, `rectangle`,
  `ellipse`, `line`, `arrow`, `blur`, `pixelate` and `stepBadge`. `arrow` is the
  diagonal, annotation kind — `arrowLeft` and `arrowRight` are horizontal and
  belong to navigation, and an arrow tool that only ever pointed sideways would
  be a strange thing to offer.

  Two were drawn twice. `stepBadge` began as a ring with a "1" inside it and was
  indistinguishable from `info`, which is already a ring with a vertical stroke
  through it; it is now a filled disc with the numeral knocked out, which is
  also what the tool it names actually stamps on an image. And `pixelate` began
  as a bare 3x3 grid, which is `table`; filling the cells in a checker is what
  makes it a mosaic.

  No eraser. A rubber at sixteen pixels is a smudge — the same reason
  `clearFormat` is a cross — and in an editor where a mark stays an object,
  removing one is `trash`.

- `SlateColorButton` and `SlateColorPopover`, with `SlateSwatches` for the
  default grid. The button is two halves, which is the whole point: the swatch
  applies the colour it is showing, the chevron beside it opens the grid — one
  click to repeat a colour, two only when a different one is wanted.

  The grid's tints are computed from six base hues rather than listed, so a
  change to a hue cannot leave its own tints behind pointing at a colour no
  longer in the grid, and the untouched hues are themselves the middle row —
  picking "red" has to give exactly red, or it never matches again. A swatch is
  ringed rather than ticked when selected: a tick over a swatch has to be light
  on dark and dark on light, and choosing which is a guess that is wrong for
  the middle of every column.

  The kit does not know what the colour is for. "No colour" is a label and a
  callback, so it means automatic ink to a text tool and no fill to a shape
  tool, and the caller can replace the whole grid.
- A `SlateDialog`'s actions wrap instead of overflowing. A dialog has a fixed
  width, and a `Row` of three buttons with real words in them does not always
  fit — the "Save before closing?" dialog overflowed by 27 pixels, which is
  silent in release and a stripe of red in debug. It behaves exactly like a Row
  whenever they do fit.
- Twenty glyphs for text editing, all on the existing 16-unit grid:
  `strikethrough`, `numberedList`, `multilevelList`, `alignJustify`, `table`,
  `image`, `pageBreak`, `fontColor`, `highlight`, `comment`, `trackChanges`,
  `findReplace`, `lineSpacing`, `superscript`, `subscript`, `paintFormat`,
  `heading`, `pilcrow`, `ruler` and `clearFormat`. A bullet-list glyph was not added: `list`
  already is one.

  Three of them were drawn twice. Numerals crowd — three digits four units
  apart touch at this stroke weight and read as one squiggle, so each is now
  boxed inside its own row band. A pen over a rule is `highlight`, so
  `trackChanges` became the change bar a word processor prints down the margin
  instead. And a brush tapering to bristles read as a bottle, so `paintFormat`
  is a roller: all rectangles, which survive being small.
- `SlateScrollbar`, driven by an offset rather than by a `ScrollController`.
  Flutter's own `Scrollbar` needs a `ScrollPosition`, which means the thing
  being scrolled has to be a `Scrollable` — and a viewport whose two axes are
  independent, whose wheel scroll is quantised, or part of whose content is
  pinned while the rest moves has no single `ScrollPosition` to offer. A
  `SlateScrollbar.forController` named constructor covers the ordinary case.

  It carries its own thickness across its axis, per rule 4. The arrangement it
  exists for — laid over a viewport inside a `Stack`, positioned on three edges
  — leaves the fourth unbounded, so a widget that took whatever the parent
  offered would assert, naming this file rather than the caller.
- `SlateMetrics.scrollbarThickness`, 11. Deliberately not scaled by `scaled()`,
  for the same reason `splitterHitExtent` is not: it is a pointer target, and a
  pointer does not get smaller because the interface is dense.

- **`SlateIcons.paperclip`** — the attach glyph.

  Every editor that lets you write also lets you attach, and the set had no
  glyph for it: `link` is two chain rings and reads as a relation between two
  things, not as a file coming along with a message.

  Drawn as one open stroke. The gap at the bottom left is what makes it a clip
  rather than a bent tube, and it is the first thing to disappear when a
  paperclip is drawn too small — which is why the curve radii are on the same
  16-unit grid as the rest rather than eyeballed.

- **`SlateActivityItem.label`** — a name drawn under the rail icon.

  The icons-only rail is the right default for a tool someone lives in: five
  glyphs are learned in a day and the space pays for itself every day after.
  It is the wrong one for a tool someone opens twice a week, where the first
  minute goes on guessing. The kit cannot know which an application is, so it
  now takes the answer as a parameter.

  The item box stays square, so a label is clipped to
  `SlateMetrics.activityBarWidth` rather than making one destination taller
  than its neighbours — widen the bar before turning labels on. Unset by
  default; an existing rail is unchanged.

- **`SlateTab.preview` and `SlateTabStrip.onPinned`** — the transient tab.

  A preview tab is drawn in italic and reported as such; the strip fires
  `onPinned` on the second click of a pair, and the caller decides what pinning
  means. Which tab is a preview stays the application's business — the strip
  only draws the state and reports the gesture.

  The pair is counted inside the strip rather than through `GestureDetector`'s
  `onDoubleTap`, which would hold the gesture arena open for the whole
  double-tap timeout and delay every single click by 300 ms. A preview tab
  exists to make one click cheap, and that is the one delay it cannot afford.

## [0.7.0] - 2026-08-08

### Added

- **`showSlateContextMenu` and `SlateContextMenuItem`** — the right-click
  popup, reusing the menu-bar row rendering so the two look like one thing.

  Items are values rather than widgets, unlike the menu bar's. A context menu
  has to close *before* it runs anything — a popup still covering the row it
  just changed hides the result — and that is only possible if the menu owns
  the callback instead of being handed an opaque child.

  A menu opened near an edge is flipped back inside the window. One that spills
  off the bottom is one whose last row cannot be reached, and the last row is
  usually the destructive one.

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
