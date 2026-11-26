---
name: issue
description: Create a GitHub issue (Story, Task, Bug, Spike) in a repo that follows btmx-sdlc conventions (docs/conventions.md). Sets the issue type and, for a Task, the parent Story.
---

# skill:issue

> **Placeholder.** How Stories and Tasks are created depends on the spec method (TDD, BDD, OpenSpec, Spec Kit), which is not decided yet — see docs/conventions.md §6 "Decide later". Until then this skill does only the minimal steps below.

## Steps

1. Pick the type:
   - `Story`: user-facing slice ("as a user I can X"). Parent of Tasks, no PR of its own.
   - `Task`: one unit of agent work, 1 Task = 1 PR. Needs an open parent Story; if there is none, ask the user.
   - `Bug`: something that worked and broke.
   - `Spike`: research for one question; output: spike report.
   - Never use `Feature`.
2. Write the title: imperative, sentence case, ≤ 60 chars, no ID, no type (`Set up db`).
3. Write the body from `template/issue.tpl` to a file. Do not list Tasks in a Story body. Do not write the parent in a Task body: GitHub shows both.
4. Create the issue:
   ```bash
   gh issue create --title "<title>" --body-file "<file>" --type <Story|Task|Bug|Spike>            # Story, Bug, Spike
   gh issue create --title "<title>" --body-file "<file>" --type Task --parent <story-number>    # Task
   ```
   If `gh` has no `--type` flag (older version), create without it and set the type:
   `gh api -X PATCH repos/{owner}/{repo}/issues/<n> -f type=<Type>`.
5. Priority: only when the user asks. See docs/conventions.md §1 for the API call.
6. Report the issue URL.
