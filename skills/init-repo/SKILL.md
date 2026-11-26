---
name: init-repo
description: Sets up a GitHub repo for the btmx-sdlc workflow (pre-commit hooks, AGENTS.md block, PR title check, merge settings, ruleset). Use when the user asks to set up, init or create a repo for this workflow.
---

# Goal

Make the gates in docs/conventions.md §5 work in one repo.

# Conventions

* `<skill>`: this skill's folder; files to copy are in `<skill>/config/`
* `<sdlc>`: the btmx-sdlc repo (two levels up from `<skill>`)
* `<repo>`: local clone of the target repo

# Procedure

> Execute all steps below in order, top to bottom.

## Step 0: Verify prerequisites

```bash
gh auth status
pre-commit --version
gh api user/issue-types -q '.[].name'
```

* If `gh` is not logged in: output `"Run gh auth login first"` and STOP.
* If `pre-commit` is missing: output `"Install pre-commit: brew install pre-commit"` and STOP.
* If `Story`, `Task`, `Bug` or `Spike` is missing (or the call fails): note it for the Output and continue — the user adds types in Settings → Planning → Issue types; do not create them.

## Step 1: Get repo

* If the user named an existing repo: use its clone (otherwise `gh repo clone <owner>/<name>`).
* Else if the user asked for a new repo: `gh repo create <owner>/<name> --public --clone && git -C <name> symbolic-ref HEAD refs/heads/main` — the empty clone starts on git's default branch (often `master`), and Step 3 pushes `main`.
* Otherwise: ask which repo and STOP.
* Record visibility: `gh repo view --json visibility -q .visibility`.

## Step 2: Add files

```bash
cp <skill>/config/.pre-commit-config.yaml <repo>/
mkdir -p <repo>/.github/workflows
cp <skill>/config/.github/workflows/pr-title.yml <repo>/.github/workflows/
```

* Append `<skill>/config/AGENTS.md` to `<repo>/AGENTS.md` (create it if missing; skip if the block is already there).
* `<repo>/CLAUDE.md` contains the line `@AGENTS.md` (create the file if missing) — Claude Code reads CLAUDE.md.

## Step 3: Commit to main

```bash
cd <repo>
git add .pre-commit-config.yaml .github/workflows/pr-title.yml AGENTS.md CLAUDE.md
git commit -m "chore: add btmx-sdlc conventions"
git push origin main
```

* Hooks are not installed yet, so this commit on `main` is allowed — `pr-title` must be on `main` before Step 6.
* If the push is rejected (ruleset already on `main`): output `"main is protected: create an issue and use skill:pr"` and STOP.

## Step 4: Install hooks

```bash
pre-commit install
```

## Step 5: Merge settings

```bash
gh repo edit --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
gh api -X PATCH repos/{owner}/{repo} -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
```

## Step 6: Ruleset on main

* If visibility is `PUBLIC` (or the user says the account has GitHub Pro): run the ruleset command from `<sdlc>/docs/conventions.md` §5 "Repo setup".
* Otherwise: skip — private repo on GitHub Free.

# Verification

1. `ls <repo>/.git/hooks/pre-commit <repo>/.git/hooks/commit-msg`
2. `git -C <repo> ls-tree -r --name-only origin/main | grep -E 'pre-commit-config|pr-title.yml|AGENTS.md|CLAUDE.md'` lists 4 files
3. `gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed,deleteBranchOnMerge` → `true`, `false`, `false`, `true`
4. If Step 6 ran: `gh api repos/{owner}/{repo}/rulesets -q '.[].name'` contains `main`

# Output

Begin with `Repo:`. No preamble.

```
Repo: <url> (<visibility>)
Done: <steps>
Skipped: <steps and reason, or none>
Issue types missing: <names, or none>
```
