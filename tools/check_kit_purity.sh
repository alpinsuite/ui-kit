#!/usr/bin/env bash
#
# Checks that the kit stays liftable.
#
# What made this package possible to extract from an application in one piece
# was that it never reached back into one. Nothing enforced that but a rule in a
# file, and a rule in a file is checked exactly as often as someone remembers.
#
#   1. lib/ imports nothing but dart: and package:flutter.
#   2. The package declares no runtime dependency but flutter.
#   3. Nothing under lib/src/ is exported twice or missed by the entrypoint.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

STATUS=0
fail() {
  echo "  FAIL  $1" >&2
  STATUS=1
}

echo "Checking the kit's imports..."
FOREIGN="$(
  grep -rhoE "^import '[^']+'" lib/ |
    sed "s/^import '//; s/'$//" |
    grep -vE '^(dart:|package:flutter/)' |
    grep -vE '^[a-z_/]+\.dart$' |
    sort -u || true
)"
if [[ -n "$FOREIGN" ]]; then
  fail "lib/ imports something that is not Flutter or a sibling file:"
  echo "$FOREIGN" | sed 's/^/          /' >&2
  echo "        The kit must not depend on an application or a third party;" >&2
  echo "        that is what lets any application adopt it." >&2
else
  echo "  ok    only dart:, package:flutter and sibling files"
fi

echo "Checking the declared dependencies..."
DEPS="$(
  awk '
    /^dependencies:/ { inside = 1; next }
    /^[a-z_]+:/ { inside = 0 }
    inside && /^  [a-z_]+:/ { gsub(/[ :]/, ""); print }
  ' pubspec.yaml
)"
if [[ "$DEPS" != "flutter" ]]; then
  fail "the package depends on more than flutter:"
  echo "$DEPS" | sed 's/^/          /' >&2
else
  echo "  ok    flutter only"
fi

echo "Checking the exports..."
ENTRYPOINT="lib/slate_ui.dart"
for file in lib/src/*.dart; do
  name="$(basename "$file")"
  count="$(grep -c "^export 'src/$name';$" "$ENTRYPOINT" || true)"
  if [[ "$count" -eq 0 ]]; then
    fail "lib/src/$name is not exported by $ENTRYPOINT"
  elif [[ "$count" -gt 1 ]]; then
    fail "lib/src/$name is exported $count times by $ENTRYPOINT"
  fi
done
for export in $(sed -n "s/^export 'src\/\([^']*\)';$/\1/p" "$ENTRYPOINT"); do
  if [[ ! -f "lib/src/$export" ]]; then
    fail "$ENTRYPOINT exports src/$export, which does not exist"
  fi
done
if [[ "$STATUS" -eq 0 ]]; then
  echo "  ok    every source file is exported exactly once"
fi

exit "$STATUS"
