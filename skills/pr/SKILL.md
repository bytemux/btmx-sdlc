---
name: pr
description: Open a pull request in a repo that follows btmx-sdlc conventions (docs/conventions.md). Use when work on a Task, Bug or Spike branch is ready for review. Does not merge.
---

# skill:pr

Opens a draft PR for the current branch. The PR title becomes the commit on `main` (squash merge), so it must be a valid Conventional Commit.

## Steps

1. Read the branch and the issue number:
   ```bash
   b=$(git branch --show-current)
   echo "$b" | grep -Eqx '(feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert)/[0-9]+-[a-z0-9-]+' || { echo "bad branch: $b"; exit 1; }
   type=${b%%/*}; rest=${b#*/}; n=${rest%%-*}
   ```
   If the branch does not match, stop and tell the user.
2. Check the issue is open: `gh issue view "$n" --json title,state`.
3. Write the title: `<type>[(scope)][!]: <description>`.
   - `<type>`: the branch type, unless the change is clearly another type.
   - Description: what the PR changes, lowercase imperative, often close to the issue title. Total ≤ 72 chars.
   - Scope: optional, lowercase, a part of the code (`api`, `ui`). Never an issue number.
   - `!`: breaking change.
4. Check the title before creating the PR:
   ```bash
   echo "$title" | grep -Eq '^(feat|fix|refactor|perf|test|docs|style|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: \S' \
     && [ ${#title} -le 72 ] || { echo "bad title: $title"; exit 1; }
   ```
5. Write the body to a file. First line `Closes #<n>`, then the repo's PR template (`.github/pull_request_template.md` if it exists), else:
   ```md
   Closes #<n>

   ## What
   ## How to check
   ```
6. Push and open a draft PR:
   ```bash
   git push -u origin "$b"
   gh pr create --draft --base main --head "$b" --title "$title" --body-file "$body"
   ```
7. Report the PR URL.

## Do not

- Merge the PR, unless the user asks directly. Then: `gh pr merge <url> --squash`.
- Edit the title on GitHub after creating it, except to fix a rule from step 3.
- Open a PR from `main` or from a branch that does not match step 1.
