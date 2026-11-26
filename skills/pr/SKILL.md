---
name: pr
description: Opens a draft PR for the current branch with a Conventional Commits title and a body that closes the issue. Use when work on a Task, Bug or Spike branch is ready, or the user asks to open a PR.
---

# Goal

Open a draft PR whose title is a valid squash commit for `main`.

# Conventions

* `<types>`: `feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert`
* Branch: `<type>/<n>-<slug>`; `<n>` = issue number
* Title: `<type>[(scope)][!]: <description>`, ≤ 72 chars

# Procedure

> Execute all steps below in order, top to bottom.

## Step 0: Verify branch and issue

```bash
b=$(git branch --show-current)
echo "$b" | grep -Eqx '(feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert)/[0-9]+-[a-z0-9-]+'
rest=${b#*/}; n=${rest%%-*}
gh issue view "$n" --json title,state
```

* If the branch does not match: output `"Branch <b> does not match <type>/<n>-<slug>"` and STOP.
* If the issue state is not `OPEN`: output `"Issue #<n> is not open"` and STOP.

## Step 1: Write title

* `<type>`: the branch type (otherwise the type that fits the change better)
* Description: what the PR changes, lowercase imperative, close to the issue title
* Scope: optional, lowercase code area (`api`, `ui`), never an issue number
* `!`: only for a breaking change
* Example: issue `Set up db` on `feat/21-set-up-db` → `feat: set up db`

## Step 2: Check title

```bash
echo "$title" | grep -Eq '^(feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: \S' && [ ${#title} -le 72 ]
```

* If the check fails: rewrite the title (Step 1) and check again. Otherwise: go to Step 3.

## Step 3: Write body

* Line 1: `Closes #<n>`
* Then `.github/pull_request_template.md` (if present; otherwise `## What` and `## How to check`)

## Step 4: Push and open draft PR

```bash
git push -u origin "$b"
gh pr create --draft --base main --head "$b" --title "$title" --body-file "$body"
```

* **Do not merge unless the user asks directly.** Then: `gh pr ready <url> && gh pr merge <url> --squash` — GitHub does not merge a draft PR.

# Output

Begin with the PR URL. No preamble.
