# CLAUDE.md

Working notes for agents making changes here. Human-facing documentation lives
in [README.md](README.md) and [docs/](docs/); this file is the short version of
what you need before touching the code.

## What this is

A Flutter widget kit for desktop tools, published as the `slate_ui` package. It
was extracted from [rbuache/paint](https://github.com/rbuache/paint), where it
lived as `lib/slate/` and was written from the start to be lifted out.

## Environment

The Flutter SDK is **not** preinstalled in a fresh container. Install it before
running anything:

```bash
curl -sSL -o /tmp/flutter.tar.xz \
  https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.44.8-stable.tar.xz
tar xf /tmp/flutter.tar.xz -C /opt
git config --global --add safe.directory /opt/flutter   # required when running as root
export PATH="/opt/flutter/bin:$PATH"

# Only needed to build the example.
apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

Pin **3.44.8** — it is what CI uses.

## Commands

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
bash tools/check_kit_purity.sh
flutter test

cd example && flutter test && flutter build linux --release

tools/set_version.sh          # print version; pass one to set it
```

Run all five before claiming a change is done. They are exactly what the CI
analyze job runs, so a green local run means that job is green.

## Seeing a change

There is no display in the container, but the gallery runs fine under Xvfb.
This is the only way to verify anything about how the kit actually looks:

```bash
apt-get install -y xvfb x11-utils xdotool imagemagick
nohup Xvfb :99 -screen 0 1400x900x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
export DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1
cd example/build/linux/x64/release/bundle && nohup ./slate_ui_example &
sleep 12                                    # first frame takes a while
import -display :99 -window root /tmp/shot.png
```

Then read `/tmp/shot.png`. `xdotool mousemove X Y click 1` drives it. Half this
kit's design lives in the hover state, so `xdotool mousemove` without a click is
often the thing worth doing — a widget test can assert a colour, but only a
screenshot shows a menu overlapping a bar or a label truncating.

Never use `pkill -f <pattern>` where the pattern also appears in the command you
are running — it matches your own shell and kills the session.

## Rules that matter

1. **The kit knows nothing about any application.** No controllers, no models,
   no localisations, no domain concepts, and no user-facing string literals —
   every label and tooltip is a parameter, so the caller owns translation.
   `tools/check_kit_purity.sh` enforces the mechanical half of this; the rest is
   judgement.

2. **Nothing but Flutter goes in `dependencies`.** A widget kit that drags a
   state-management or icon package behind it is one an application has to
   negotiate with rather than adopt.

3. **Every source file under `lib/src/` is exported exactly once by
   `lib/slate_ui.dart`.** That file is the whole public surface.

4. **Every control carries an explicit height from `SlateMetrics`.** Left to
   their intrinsic sizes, controls inherit the ambient line height and grow to
   fill whatever row they are in, which is what makes an interface look inflated
   even when the type is the right size.

5. **Colours come from `SlatePalette`, sizes from `SlateMetrics`.** A literal
   `Color` or a magic number in a widget is a value that cannot be themed, and
   it will be the one thing that looks wrong in the other palette. The
   exceptions already in the tree are `Color(0x00000000)` for "no background"
   and the small paddings that are part of a specific control's shape.

6. **Icons are paths on a 16-unit grid, added as static methods on
   `SlateIcons`.** No font, no asset. Match the existing stroke weight and grid;
   uniformity is most of what makes a set feel like one piece of software. A new
   glyph goes into the map in `example/lib/main.dart` and the one in
   `test/slate_icons_test.dart` in the same change.

7. **A `SlateMenuScope` goes *above* its `MenuAnchor`, never inside the
   anchor's `builder`.** The panel is an overlay child and inherits only from
   the anchor's ancestors. Putting it in the builder compiles fine and silently
   does nothing.

8. **A visual change is an API change.** A consumer's interface is built out of
   these colours and sizes. Changing one is a minor bump, not a patch, even
   though the analyzer will not say so.

## Layout

```
lib/slate_ui.dart   the entrypoint; the entire public surface
lib/src/            one file per area — palette, metrics, theme, icons,
                    controls, select, menu, dialog
example/            the gallery, and the only thing that compiles the kit into
                    a real binary
test/               one file per source file, plus slate_test_harness.dart
tools/              set_version.sh, check_kit_purity.sh
docs/               RELEASING.md, MIGRATING.md
```

`slate_theme.dart` is the hub: everything imports it for `context.slate`, and it
imports only the palette and the metrics. Keep that direction — a widget file
importing another widget file is fine, but the theme importing a widget is a
cycle waiting to happen.

## Gotchas discovered the hard way

- `dart format` reformats aggressively. Anchor-based patch scripts written
  against pre-format source will stop matching — read the file first.
- A `SemanticsHandle` from `tester.ensureSemantics()` must be disposed *inside*
  the test body. The framework checks for outstanding handles before tear-downs
  run, so `addTearDown(handle.dispose)` fails the test it was meant to clean up.
- `containsSemantics` and `matchesSemantics` are deprecated; use `isSemantics`.
- A `Row` inside a horizontal `SingleChildScrollView` needs
  `mainAxisSize: MainAxisSize.min`, and cannot contain a `Spacer` — the main
  axis is unbounded.
- `find.byType(SlateSelect)` and friends match the widget, not the box it
  draws; `tester.getSize` on a widget whose root is a `Dialog` returns the
  screen. Measure the `Container` descendant.
- The example's `pubspec.yaml` uses `path: ../`, so a change to the kit is
  picked up without a `pub get` — but a change to the kit's *pubspec* is not.
- `flutter create` in `example/` regenerates `pubspec.yaml`, `lib/main.dart`
  and a default counter test. Back those up before running it to add a
  platform.

## Before finishing

- All five checks pass, and the example builds.
- New behaviour has tests; a new widget has a section in the gallery.
- User-visible changes have a `CHANGELOG.md` entry under `## [Unreleased]`.
- Do not bump the version in a normal change — releases do that
  ([docs/RELEASING.md](docs/RELEASING.md)).
- Comments explain *why*, never *what*.
