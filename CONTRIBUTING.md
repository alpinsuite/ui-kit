# Contributing

## Setting up

The kit needs the Flutter SDK, pinned to the version CI uses:

```bash
curl -sSL -o /tmp/flutter.tar.xz \
  https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.44.8-stable.tar.xz
tar xf /tmp/flutter.tar.xz -C /opt
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
```

Building the gallery additionally needs the Linux desktop toolchain:

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

## Before opening a pull request

```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
bash tools/check_kit_purity.sh
flutter test

cd example && flutter test && flutter build linux --release
```

These are exactly what CI runs. A green local run means a green CI run, with one
exception: CI builds the gallery on a clean runner, so a missing file that your
working tree happens to have will only fail there.

## What belongs in the kit

The kit takes widgets that any desktop tool could use. It does not take anything
that knows what the application *is*.

Concretely, a change is out of scope if it introduces:

- a controller, a model, or anything that holds application state;
- a user-facing string literal — labels and tooltips are parameters, so the
  caller owns translation;
- a dependency other than Flutter;
- an import from outside `dart:` and `package:flutter/`.

`tools/check_kit_purity.sh` catches the last two. The first two need a reviewer.

If a widget is nearly general but needs one application-specific thing, the
answer is almost always another parameter rather than an exception.

## House style

- Colours come from `SlatePalette`, sizes from `SlateMetrics`. A literal colour
  or a magic number is a value that cannot be themed.
- Every control pins its own height.
- Comments explain *why*, never *what*. If a line needs a comment to say what it
  does, rewrite the line.
- New behaviour gets a test. A new widget gets a section in `example/`.

## Changelog

Add an entry under `## [Unreleased]` in `CHANGELOG.md`, grouped under
**Added**, **Changed**, **Fixed**, **Deprecated** or **Removed**. The release
workflow copies that section verbatim into the GitHub Release, so write it for
someone consuming the package rather than as a commit log.

Do not bump the version — [releases](docs/RELEASING.md) do that.

## Commits

One logical change per commit, with a message that says why. The diff already
says what.
