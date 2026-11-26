# Conventions: issues, PRs, branches, commits (GitHub)

Nov 26, 2026 · @Mike · draft 4 · commits and PR titles follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)

## Summary

| Item | Format | Example |
| --- | --- | --- |
| Issue | `<Title>` + issue type (+ field `Priority` if asked) | `Replicate db` (Story) → `#20` |
| Task | sub-issue of a Story, same title rules | `Set up db` (Task) → `#21` |
| Branch | `<type>/<n>-<slug>`, `<n>` = Task, Bug or Spike | `feat/21-set-up-db` |
| Commit | `<type>[(scope)][!]: <description>` | `feat: add db container` |
| PR | `<type>[(scope)][!]: <description>` + body `Closes #<n>` | `feat: set up db` |
| Commit on `main` | PR title + `(#PR)`, body = PR body | `feat: set up db (#23)` / `Closes #21` |

`<type>`: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `build`, `ci`, `chore`, `revert`.

## 1. Issue

- Title: imperative, sentence case, ≤ 60 chars, no ID, no type.
- Types (issue type):
  - `Story` — user-facing slice, parent of Tasks.
  - `Task` — one unit of agent work, sub-issue of a Story.
  - `Bug` — something that worked and broke.
  - `Spike` — research for one question; output: spike report.
- Priority: issue field `Priority` (starter field, single-select). Options, highest first: `Urgent`, `High`, `Medium`, `Low`. Optional: set only when the user asks.
- Optional fields: `Start date`, `Target date`, `Effort`.
- Body: `template/issue.tpl`. No Task list in a Story body, no parent link in a Task body: GitHub shows both.
- Set type: `gh api -X PATCH repos/{owner}/{repo}/issues/<n> -f type=<Story|Task|Bug|Spike>`.
- Set priority: `gh api -X POST repos/{owner}/{repo}/issues/<n>/issue-field-values -H 'X-GitHub-Api-Version: 2026-03-10' --input - <<< '{"issue_field_values":[{"field_id":<id>,"value":"<option>"}]}'`. `value` = option name (`High`). Reading the values back (`GET` same path) returns the option id in `value` and the name in `single_select_option.name`.
- Field id (user-owned repo): `gh api -H 'X-GitHub-Api-Version: 2026-03-10' user/issue-fields -q '.[] | select(.name=="Priority") | .id'`. Option order: `.options | sort_by(.priority)`.

## 2. Task

- Task = sub-issue of a Story. 1 Task = 1 branch = 1 PR.
- The Story shows its Tasks and their progress in its Sub-issues section; the Task shows its parent in the sidebar.
- Story has no PR of its own. Close it by hand when all its Tasks are closed: GitHub does not close a parent issue when its sub-issues close.
- A Task closes when its PR is squash-merged (`Closes #<n>` in the PR body), a few seconds after the merge.
- Bug and Spike: no Tasks, 1 branch = 1 PR.
- Create a Task: `gh issue create --title "<title>" --body-file <file> --parent <story>`.

## 3. PR

- Title: `<type>[(scope)][!]: <description>`. Description: what the PR changes, lowercase imperative, often close to the issue title. ≤ 72 chars.
- Scope: optional, a part of the code (`api`, `ui`). Never an issue number.
- `!` after type or scope: breaking change.
- Spike PR (spike report only): type `docs`.
- Created with `skill:pr`. Body: `template/pr-description.tpl` + `Closes #<n>`. The PR is linked to the issue automatically when the branch was made with `gh issue develop`; `Closes #<n>` is the fallback and keeps the issue number in the commit on `main`.
- Merge: squash only, by the user. Agents open draft PRs and merge only when the user asks directly. Commit on `main` = PR title + `(#PR)`, body = PR body.

## 4. Branch and commit

- Branch: `<type>/<n>-<slug>`. Slug: `a-z0-9-`, ≤ 40 chars.
- Create branch: `gh issue develop <n> --name <branch> --base main --checkout`. It creates the branch on GitHub (linked to the issue under "Development") and checks it out locally.
- Commit: same format as PR title. Issue reference in the footer if needed: `Refs #<n>`.

## 5. Gates

| Gate | Rule | Managed by | Status |
| --- | --- | --- | --- |
| Commit message | Conventional Commits, first line | pre-commit `conventional-commit-msg` (commit-msg) | local |
| Branch name, no commits on `main` | `<type>/<n>-<slug>`; `main` and `master` blocked | pre-commit `no-commit-to-branch` (at commit) | local |
| PR title | Conventional Commits | `skill:pr` builds it; Action `pr-title` checks it | GitHub: required by ruleset |
| Merge only via PR, squash only | — | ruleset on `main` | GitHub: public repo or Pro |
| Commit on `main` = PR title | — | repo merge settings | GitHub |
| PR body | template + `Closes #<n>` | `skill:pr` | agent skill |
| PR linked to its issue, issue closed on merge | — | branch from `gh issue develop` (auto link); `Closes #<n>` as fallback | GitHub |
| Issue type set; Task has a Story parent | every issue has a type; every Task is a sub-issue of a Story | `skill:issue` | agent skill |
| Hooks installed in a clone | `pre-commit install` | `skill:init-repo` | agent skill |

Target: public repos on GitHub Free. A private repo on Free has no ruleset: `pr-title` only reports, and merge via PR is a rule only. A gate managed by a skill holds only when the agent uses the skill. `git commit --no-verify` skips the pre-commit hooks.

### Repo setup

Merge settings:

```bash
# 3 merge methods, each on/off; only squash stays on
gh repo edit \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge          # delete the PR branch on GitHub after merge
# squash commit = PR title + (#PR), body = PR body
gh api -X PATCH repos/{owner}/{repo} -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
```

Pre-commit hooks: copy `skills/init-repo/config/.pre-commit-config.yaml` to the repo root, then:

```bash
pre-commit install      # pre-commit and commit-msg hooks
```

PR title check: copy `skills/init-repo/config/.github/workflows/pr-title.yml` to the repo and merge it to `main` before adding the ruleset. It runs `amannn/action-semantic-pull-request` with the 11 types; Actions are free on public repos.

Ruleset on `main` (public repo or GitHub Pro): PR required, squash only, `pr-title` check required, admin bypass:

```bash
gh api -X POST repos/{owner}/{repo}/rulesets --input - <<'JSON'
{
  "name": "main", "target": "branch", "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "bypass_actors": [ { "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" } ],
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 0, "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false, "require_last_push_approval": false,
        "required_review_thread_resolution": false, "allowed_merge_methods": ["squash"] } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [ { "context": "pr-title" } ] } }
  ]
}
JSON
```

## 6. Decide later

**Spec method and Task tracking.** Decide together with the method in `draft-1` (TDD, BDD, OpenSpec, Spec Kit).

- Now: `skill:issue` creates the issue, sets its type and, for a Task, the parent (`--parent <story>`).
- OpenSpec: no GitHub Issues in core; tasks live in `tasks.md`. If chosen: 1 Story = 1 OpenSpec change, `skill:issue` creates one Task per `tasks.md` section, 1 Task = 1 PR.
- Spec Kit: has a built-in `taskstoissues` command (`tasks.md` → GitHub issues). Heavier setup.
