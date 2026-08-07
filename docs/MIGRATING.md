# Migrating an application onto the package

These are the steps for [rbuache/paint](https://github.com/rbuache/paint), which
is where the kit came from. The shape is the same for any application that
vendored `lib/slate/`.

`tools/migrate_paint.sh` in this repository performs steps 1–3 against a paint
checkout. It is idempotent, and it prints what it changed.

```bash
bash tools/migrate_paint.sh /path/to/paint 0.1.0
```

## 1. Depend on the package

In paint's `pubspec.yaml`, alongside the other dependencies:

```yaml
dependencies:
  slate_ui:
    git:
      url: https://github.com/alpinsuite/ui-kit.git
      ref: v0.1.0
```

Pin the tag, not `main`. A branch ref re-resolves whenever the branch moves, so
an unrelated `pub get` becomes an unannounced upgrade of the entire interface.

Note the consequence of a git dependency: it does not take part in pub's version
solving. Upgrading is editing this `ref` — a commit someone can review and
revert, which is the behaviour you want here anyway.

## 2. Rewrite the imports

Eleven files import the kit by relative path. They all become the same line:

```dart
import 'package:slate_ui/slate_ui.dart';
```

| File | Was |
|---|---|
| `lib/app.dart` | `import 'slate/slate.dart';` |
| `lib/core/theme/app_theme.dart` | `import '../../slate/slate.dart';` |
| `lib/ui/app_menu_bar.dart` | `import '../slate/slate.dart';` |
| `lib/ui/app_shell.dart` | `import '../slate/slate.dart';` |
| `lib/ui/color_panel.dart` | `import '../slate/slate.dart';` |
| `lib/ui/color_picker_dialog.dart` | `import '../slate/slate.dart';` |
| `lib/ui/dialogs.dart` | `import '../slate/slate.dart';` |
| `lib/ui/status_bar.dart` | `import '../slate/slate.dart';` |
| `lib/ui/tool_options_bar.dart` | `import '../slate/slate.dart';` |
| `lib/ui/tool_palette.dart` | `import '../slate/slate.dart';` |
| `lib/ui/window_bar.dart` | `import '../slate/slate.dart';` |

`package:` imports sort before relative ones, so `directives_ordering` will want
the line moved up in files that have both. `dart format` does not do this;
`dart fix --apply` does.

No other code changes. The kit was extracted unchanged — same class names, same
parameters, same behaviour.

## 3. Delete the vendored copy

```bash
git rm -r lib/slate
```

## 4. Update paint's own documentation

- **`CLAUDE.md` rule 11** describes `lib/slate/` as "a widget kit destined to
  become its own package". It has become one. Replace the rule with the version
  that matters now: reach for a Material widget in `lib/ui/` only when the kit
  genuinely has no equivalent, and when it plausibly should have one, add it
  **in the kit's repository** and bump the `ref`.
- **`CLAUDE.md` layout section** — drop the `lib/slate/` line, and the
  `ui → slate` dependency arrow becomes a package dependency.
- **`docs/ARCHITECTURE.md`** — same, wherever it describes the directory.
- **`CHANGELOG.md`** — an entry under `## [Unreleased]`. This is not
  user-visible, so keep it short: the interface is unchanged, the code that
  draws it now lives elsewhere.

## 5. Verify

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter gen-l10n && git diff --quiet -- lib/l10n/generated
bash tools/check_hardcoded_strings.sh
flutter test
flutter build linux --release
```

Then run the application and draw something. The migration is a no-op by
construction, so anything that looks different is a real difference and worth
finding before it ships.

## Afterwards

Changing a colour, a metric or a control now means a change in this repository,
a release, and a `ref` bump in paint. That is more ceremony than editing
`lib/slate/` in place, and it is the point: the interface acquires a version
number, and a change to it becomes something a consumer opts into.

While the kit is the only consumer's dependency and both move together, the
overhead is real. `path: ../ui-kit` in paint's pubspec during a session of
back-and-forth work is a reasonable temporary state — just never commit it, as
it only resolves on the machine where both are checked out side by side.
