---
name: init-repo
description: Set up a GitHub repo for the btmx-sdlc workflow (docs/conventions.md) — pre-commit hooks, AGENTS.md block, PR title check, merge settings and ruleset. Use on a new or existing repo, or to create one.
---

# skill:init-repo

Sets up a repo so that the gates in docs/conventions.md §5 work.
Defaults: GitHub for code and issues, Python stack. Ask the user only if the repo needs something else.

## Before you start

- Tools: `git`, `gh` (logged in), `pre-commit` (`brew install pre-commit` if missing).
- Repo: use the one the user names, or create it: `gh repo create <owner>/<name> --public --clone`.
- Visibility: `gh repo view --json visibility -q .visibility`. Step 6 needs a public repo or GitHub Pro.
- Account (once per account, not per repo): issue types `Story`, `Task`, `Bug`, `Spike` exist (Settings → Planning → Issue types). If not, tell the user; do not create them.

Files to copy are in this skill's `config/` folder.

## Steps

1. Pre-commit hooks:
   ```bash
   cp config/.pre-commit-config.yaml <repo>/
   cd <repo> && pre-commit install
   ```
2. AGENTS.md: add the block from `config/AGENTS.md` to the repo's `AGENTS.md` (create it if missing). If the repo has a `CLAUDE.md`, make sure it contains the line `@AGENTS.md`; if there is none, create `CLAUDE.md` with that line.
3. PR title check: copy `config/.github/workflows/pr-title.yml` to `<repo>/.github/workflows/`.
4. Commit steps 1–3 and merge them to `main` (through a branch and a PR if `main` already has a ruleset). The `pr-title` workflow must be on `main` before step 6.
5. Merge settings:
   ```bash
   gh repo edit --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
   gh api -X PATCH repos/{owner}/{repo} -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
   ```
6. Ruleset on `main` (public repo or GitHub Pro; skip on a private repo on Free): run the `gh api … /rulesets` command from docs/conventions.md §5 "Repo setup".
7. Report what was done and what was skipped (for example step 6 on a private repo).

## Do not

- Change account settings (issue types, issue fields) without asking.
- Push to `main` with `--no-verify` without asking.
