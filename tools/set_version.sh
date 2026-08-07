#!/usr/bin/env bash
#
# Sets the package version and prepares the changelog for a release.
#
#   tools/set_version.sh 1.2.3
#
# pubspec.yaml is the single source of truth. Unlike an application, a library
# has no build number: pub resolves plain semantic versions, and a `+build`
# suffix on a published package is noise a dependant has to look at.
#
# With no argument it prints the current version, which is what CI uses to check
# that a tag matches.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

current_version() {
  sed -n 's/^version: *\([0-9][^ +]*\).*/\1/p' pubspec.yaml
}

if [[ $# -eq 0 ]]; then
  current_version
  exit 0
fi

VERSION="$1"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]]; then
  echo "not a semantic version: $VERSION" >&2
  echo "expected MAJOR.MINOR.PATCH, optionally with a -prerelease suffix" >&2
  exit 2
fi

PREVIOUS="$(current_version)"
if [[ "$VERSION" == "$PREVIOUS" ]]; then
  echo "already at $VERSION" >&2
  exit 2
fi

# Refuse to go backwards. A published version number is permanent: pub.dev will
# not accept a re-upload, and a dependant that has already resolved the higher
# version would silently keep it.
if [[ "$(printf '%s\n%s\n' "$PREVIOUS" "$VERSION" | sort -V | head -n1)" != "$PREVIOUS" ]]; then
  echo "$VERSION is older than the current $PREVIOUS" >&2
  exit 2
fi

sed -i "s/^version: .*/version: $VERSION/" pubspec.yaml
if ! grep -q "^version: $VERSION$" pubspec.yaml; then
  echo "failed to set the version in pubspec.yaml" >&2
  exit 1
fi

DATE="$(date -u +%Y-%m-%d)"

# Turn the Unreleased heading into this version's, and open a fresh empty one
# above it. Doing this by hand is how a release ends up with either no notes or
# someone else's.
if grep -q '^## \[Unreleased\]' CHANGELOG.md; then
  python3 - "$VERSION" "$DATE" <<'PY'
import sys

version, date = sys.argv[1], sys.argv[2]
with open('CHANGELOG.md') as handle:
    text = handle.read()

text = text.replace(
    '## [Unreleased]\n',
    f'## [Unreleased]\n\n## [{version}] - {date}\n',
    1,
)

with open('CHANGELOG.md', 'w') as handle:
    handle.write(text)
PY
else
  echo "warning: no '## [Unreleased]' heading in CHANGELOG.md; add the" >&2
  echo "         '## [$VERSION] - $DATE' section by hand" >&2
fi

echo "version set to $VERSION (was $PREVIOUS)"
echo
echo "Next steps:"
echo "  1. Check the [$VERSION] section of CHANGELOG.md reads for users"
echo "  2. git commit -am \"Release $VERSION\""
echo "  3. git tag -a v$VERSION -m \"Release $VERSION\" && git push --follow-tags"
echo
echo "Pushing the tag runs the checks and publishes the GitHub release."
