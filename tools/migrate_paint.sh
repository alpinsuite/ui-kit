#!/usr/bin/env bash
#
# Points a paint checkout at the slate_ui package instead of its vendored copy.
#
#   tools/migrate_paint.sh /path/to/paint 0.1.0
#
# Adds the git dependency, rewrites the eleven relative imports, and removes
# lib/slate/. It does not touch paint's documentation or its changelog; see
# docs/MIGRATING.md for what still needs a human.
#
# Idempotent: running it twice is a no-op the second time.

set -euo pipefail

PAINT="${1:-}"
VERSION="${2:-}"

if [[ -z "$PAINT" || -z "$VERSION" ]]; then
  echo "usage: tools/migrate_paint.sh /path/to/paint VERSION" >&2
  echo "  e.g. tools/migrate_paint.sh ../paint 0.1.0" >&2
  exit 2
fi

if [[ ! -f "$PAINT/pubspec.yaml" ]] || ! grep -q '^name: paint$' "$PAINT/pubspec.yaml"; then
  echo "$PAINT does not look like a paint checkout" >&2
  exit 2
fi

cd "$PAINT"

REPO_URL="https://github.com/alpinsuite/ui-kit.git"
CHANGED=0

# 1. The dependency.
if grep -q '^  slate_ui:' pubspec.yaml; then
  echo "  ok    pubspec.yaml already depends on slate_ui"
else
  # Inserted at the top of `dependencies:`, after the two SDK entries, so it
  # lands somewhere a human would have put it rather than at the end.
  python3 - "$REPO_URL" "$VERSION" <<'PY'
import sys

url, version = sys.argv[1], sys.argv[2]
with open('pubspec.yaml') as handle:
    text = handle.read()

anchor = '  flutter_localizations:\n    sdk: flutter\n'
entry = (
    f'{anchor}\n'
    '  # The widget kit everything is drawn with. Pinned to a tag: a branch ref\n'
    '  # would re-resolve on any `pub get` and change the whole interface.\n'
    '  slate_ui:\n'
    '    git:\n'
    f'      url: {url}\n'
    f'      ref: v{version}\n'
)
if anchor not in text:
    raise SystemExit('could not find the flutter_localizations entry in pubspec.yaml')

with open('pubspec.yaml', 'w') as handle:
    handle.write(text.replace(anchor, entry, 1))
PY
  echo "  wrote pubspec.yaml -> slate_ui v$VERSION"
  CHANGED=1
fi

# 2. The imports.
IMPORTS="$(grep -rl "import '\(\.\./\)*\(\.\./\)*slate/slate\.dart';" lib --include='*.dart' || true)"
if [[ -z "$IMPORTS" ]]; then
  echo "  ok    no relative slate imports left"
else
  # Rewriting in place would leave a package: import sitting wherever the
  # relative one happened to sort — in the middle of the relative block. Nothing
  # downstream corrects that: `dart fix` only acts on `directives_ordering`, and
  # flutter_lints does not enable it, so the analyzer stays silent about it.
  while IFS= read -r file; do
    python3 - "$file" <<'PY'
import re
import sys

path = sys.argv[1]
target = "import 'package:slate_ui/slate_ui.dart';"
relative = re.compile(r"^import '(\.\./)*slate/slate\.dart';$")

with open(path, encoding='utf-8') as handle:
    lines = handle.read().split('\n')

lines = [line for line in lines if not relative.match(line)]

package = [i for i, line in enumerate(lines) if line.startswith("import 'package:")]
if not package:
    raise SystemExit(f'{path}: no package: import block for the kit to join')

start, end = package[0], package[-1]
if end - start + 1 != len(package):
    raise SystemExit(f'{path}: package: imports are not one contiguous block')

lines[start:end + 1] = sorted(lines[start:end + 1] + [target])

with open(path, 'w', encoding='utf-8', newline='\n') as handle:
    handle.write('\n'.join(lines))
PY
    echo "  wrote $file"
    CHANGED=1
  done <<< "$IMPORTS"
fi

# 3. The vendored copy.
if [[ -d lib/slate ]]; then
  if git rev-parse --git-dir > /dev/null 2>&1 && git ls-files --error-unmatch lib/slate > /dev/null 2>&1; then
    git rm -rq lib/slate
  else
    rm -rf lib/slate
  fi
  echo "  removed lib/slate/"
  CHANGED=1
else
  echo "  ok    lib/slate/ is already gone"
fi

echo
if [[ "$CHANGED" -eq 0 ]]; then
  echo "Nothing to do."
  exit 0
fi

cat <<'NEXT'
Next, by hand (see docs/MIGRATING.md):
  - CLAUDE.md rule 11 and the layout section
  - docs/ARCHITECTURE.md, wherever it describes lib/slate/
  - a CHANGELOG.md entry under [Unreleased]

Then:
  flutter pub get
  dart format .             # dropping the old import can leave a stray blank line
  flutter analyze --fatal-infos
  flutter test
NEXT
