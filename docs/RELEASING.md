# Releasing

## Versioning

The package follows [Semantic Versioning](https://semver.org). `pubspec.yaml` is
the **single source of truth**:

```yaml
version: 0.1.0
```

Unlike the application this kit came from, there is no `+build` suffix. Pub
resolves plain semantic versions, and a build number on a published package is
noise every dependant has to look at. CI checks the format on every run.

Since the version is below 1.0.0, the API may still change between minor
versions. What that means for a consumer:

| Change | Bump |
|---|---|
| A new widget, a new icon, a new optional parameter | Minor |
| A renamed or removed public member, a changed default, a required parameter | Minor while below 1.0.0; major after |
| A fix that leaves the public surface alone | Patch |

A colour or a metric changing is an API change in a design system, even though
the analyzer will not say so. Treat a visual change that a consumer would have
to react to as a minor bump.

## Cutting a release

```bash
# 1. Bump the version and open the changelog section
tools/set_version.sh 0.2.0

# 2. Check the section it created reads for users rather than as a commit log

# 3. Commit and tag
git commit -am "Release 0.2.0"
git tag -a v0.2.0 -m "Release 0.2.0"
git push --follow-tags
```

Pushing the tag is what triggers everything else.

`tools/set_version.sh` with no argument prints the current version, which is how
CI checks that a tag matches. With an argument it rewrites `pubspec.yaml`, turns
the `## [Unreleased]` heading into `## [0.2.0] - <today>` and opens a fresh
empty `Unreleased` above it. It refuses a version that is not semantic, that
matches the current one, or that sorts below it — a published version number is
permanent, and a dependant that already resolved a higher one would silently
keep it.

## What the tag triggers

`.github/workflows/release.yml`:

1. **Checks the tag matches the pubspec version.** A mismatch fails immediately
   with the command needed to fix it, rather than publishing something whose
   version disagrees with its tag.
2. **Checks `CHANGELOG.md` has a section for it**, because that section *is* the
   release notes.
3. Runs the formatter, the analyzer, the purity check, the tests and
   `dart pub publish --dry-run`.
4. Creates a **GitHub Release** with those notes plus the dependency snippet
   pinned to the new tag. A version containing a hyphen (`0.2.0-rc.1`) is marked
   a prerelease automatically.

## Consumers

Applications depend on a **tag**, not a branch:

```yaml
dependencies:
  slate_ui:
    git:
      url: https://github.com/alpinsuite/ui-kit.git
      ref: v0.2.0
```

`ref: main` re-resolves whenever `main` moves, so an unrelated `pub get` in the
consumer becomes an unannounced upgrade. Upgrading should be a commit in the
consumer that someone can revert.

Note that a git dependency does not participate in pub's version solving:
`^0.2.0` means nothing to it, and two packages wanting different tags of this
one cannot both be satisfied. That is the cost of not publishing, and it is
fine while the set of consumers is small.

## Publishing to pub.dev

Not set up. The release workflow runs `dart pub publish --dry-run` on every
release, so the package stays publishable and the switch is small when it is
wanted:

1. Claim `slate_ui` on pub.dev, or rename the package if it is taken.
2. Add this repository as a **trusted publisher** for it (pub.dev → the
   package → Admin → Automated publishing), which is what lets the workflow
   publish over OIDC without a long-lived credential.
3. Uncomment the `pub-dev` job at the bottom of
   `.github/workflows/release.yml`.

Doing it in that order matters: the job fails every release until the trusted
publisher exists, which is why it ships commented out rather than merely
untested.

## If a release goes wrong

Delete the release and its tag, fix the problem, and tag again with a **new
patch version**. Do not move a tag that has already been published: a consumer
that pinned it would silently get different code under the same name.

```bash
git push --delete origin v0.2.0
git tag -d v0.2.0
# fix, then
tools/set_version.sh 0.2.1
```

`workflow_dispatch` can re-run the release workflow against an existing tag if
only the publishing step failed.
