# Versioning

Nov 26, 2026 · @Mike · draft 1 · versions follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html); bumps come from [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) titles (docs/conventions.md)

## Summary

| Item | Rule | Example |
| --- | --- | --- |
| Version | `<major>.<minor>.<patch>` (SemVer) | `1.4.2` |
| Tag | `v<version>` on the released commit of `main` | `v1.4.2` |
| Source | commit titles on `main` since the latest `v<major>.<minor>.<patch>` tag; other tags (e.g. `v1.2.0-rc.1`) are ignored | `feat: add export (#12)` |
| When | every push to `main` (a merged PR); by hand (Run workflow), with an optional dry run that only prints the version | — |
| First release | no tag yet → `0.0.1` at the first releasable commit; a new repo's setup commit (`chore:`) releases nothing | — |
| Who sets it | the Release workflow only; nobody edits a version by hand | — |

## 1. Bump

The highest bump of all commits since the tag wins.

| Commit title on `main` | Bump | In changelog |
| --- | --- | --- |
| any of the 11 types with `!` (`type!:`) or a `BREAKING CHANGE:` footer line | major | yes |
| `feat` | minor | yes |
| `fix`, `perf`, `refactor`, `revert` | patch | yes |
| `docs`, `chore`, `ci`, `test`, `style`, `build` | none | no |
| no type, or a type not in the 11 (e.g. a commit from GitHub's web page) | none, warning on the run; `!` and `BREAKING CHANGE:` do not count | no |

- No releasable commit since the tag: the run ends green, no release.
- With squash merge the commit title is the PR title + `(#PR)`, so the PR title decides the bump. The `pr-title` check rejects a PR title with no type.
- The commit body is the PR body: a line in the PR body that starts with `BREAKING CHANGE:` makes a major release.
- Scope does not change the bump: `fix(ci):` is a patch release. A change that ships nothing to users takes a no-release type (`ci:`, not `fix(ci):`).
- A merge commit (`Merge pull request #N …`, repos from before squash merge) counts by the PR title in its body.
- `0.x` versions use the same rules: from `0.0.1`, a `fix` makes `0.0.2`, a `feat` makes `0.1.0`, a breaking change makes `1.0.0`.

## 2. Implementation

| Part | File (in a target repo) | Source in btmx-sdlc |
| --- | --- | --- |
| Version and changelog | `scripts/next-version.sh` | `skills/init-repo/config/scripts/` |
| Release workflow | `.github/workflows/release.yml` | `skills/init-repo/config/.github/workflows/` |
| PR title check | `.github/workflows/pr-title.yml` | same |

- The type lists live in `next-version.sh` and `pr-title.yml`: change both together.
- Test the script: `skills/init-repo/config/scripts/test-next-version.sh`.
- Run it locally (prints the next version, changes nothing): `scripts/next-version.sh`.

## 3. Decide later

- Pre-release versions (`1.2.0-rc.1`) and build metadata (`1.2.0+b1`): not used. SemVer makes both optional, so `<major>.<minor>.<patch>` alone is valid SemVer. `next-version.sh` ignores such tags.
