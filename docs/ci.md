# CI

Nov 26, 2026 · @Mike · draft 1 · GitHub Actions templates in `skills/init-repo/config/.github/workflows/`; `skill:init-repo` copies them

## Summary

| Workflow | Runs on | Job (check name) | Required on `main` | Copied by init-repo |
| --- | --- | --- | --- | --- |
| `pr-title.yml` | PR opened, edited, pushed | `pr-title` | yes (ruleset) | always |
| `release.yml` | push to `main`; by hand | `plan`, `release` | no | always |

## 1. pr-title

- Checks the PR title against Conventional Commits with the 11 types (docs/conventions.md §3).
- Plain bash, no third-party action, `permissions: {}`. The title goes through `env`, never `${{ }}` in the script: a title can hold shell code.

## 2. release

Rules: docs/versioning.md.

- `plan` (ubuntu): `scripts/next-version.sh` computes `version` and `changelog`. No version → the run ends green.
- `release`: runs only when `plan` has a version and the run is not a dry run. Steps:
  1. **Build** — a placeholder: the project replaces it with its build (and tests, if they must pass before a release). Files left in `dist/` are attached to the release. Stamp `$VERSION` into the artifacts.
  2. **Publish** — `gh release create v<version>` on the merged commit, notes = changelog.
- `concurrency: release`: runs do not overlap; a queued run computes from the tag the previous run created.
- A project that needs another runner (e.g. `macos-26` for a macOS app) changes `runs-on` of `release` only; `plan` stays on ubuntu, so the costly runner starts only when there is a release.

## 3. Rules for all workflows

- Pin every action and reusable workflow to a full-length commit SHA, with the version in a comment: `actions/checkout@<sha> # v4.4.0`. The org setting below rejects a tag or branch (`@v4`, `@main`).
- Use only actions the org setting allows (§4). Prefer plain bash in `run` when it is a few lines (e.g. `pr-title`).
- Least permissions: set `permissions` at workflow level; `{}` when no token is needed.
- Untrusted input (PR title, body, branch name) goes through `env`, never `${{ }}` inside `run`.
- Secrets: repo secrets only; name each secret and its scope in the project's docs.

## 4. Allowed actions (org setting)

The GitHub organization that owns the repos sets which actions and reusable workflows can run, for all its repos: org Settings → Actions → General → Policies.

| Setting | Value | Effect |
| --- | --- | --- |
| Policy | Allow the org's own, and select non-org, actions and reusable workflows | Actions and reusable workflows in the org's own repos are allowed; others only if a row below allows them |
| Allow actions created by GitHub | on | `actions/*` and `github/*` (e.g. `actions/checkout`) |
| Allow actions by Marketplace verified creators | on | Actions from creators with GitHub's verified badge on the Marketplace |
| Allow or block specified actions and reusable workflows | empty | No extra allow or block entries |
| Require actions to be pinned to a full-length commit SHA | on | A run that uses `@v4` or `@main` fails before it starts |

- Any other action fails the run with "not allowed". To use one: add it to the allow list (`owner/repo@<sha>`), or copy it into a repo of the org.
- A verified creator is not a code review: still read an action before you add it, and pin it (§3).
- `skill:init-repo` does not change org settings: an org admin sets them once.

## 5. Decide later

- L1 deterministic checks (types, lint, tests) as a required check: depends on each project's stack (docs/sdlc-draft-1.md §5.3).
