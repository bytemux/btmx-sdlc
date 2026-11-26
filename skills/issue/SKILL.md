---
name: issue
description: Creates a GitHub issue (Story, Task, Bug or Spike) with its issue type and, for a Task, its parent Story. Use when the user asks to create a Story, Task, Bug or Spike.
---

# Goal

Create one issue with the right type and parent.

# Conventions

* `<sdlc>`: the btmx-sdlc repo (two levels up from this skill's folder)
* Run all commands in the target repo's clone.

# Context

* Placeholder: how Stories and Tasks are created depends on the spec method, not decided yet — docs/conventions.md §6. Until then, only the steps below.

# Procedure

> Execute all steps below in order, top to bottom.

## Step 1: Pick type

* If a user-facing slice ("as a user I can X"): `Story`
* If one unit of agent work (1 Task = 1 PR): `Task` — find its open parent Story: `gh issue list --type Story --state open --json number,title`
  * If the user named the Story and it is in the list: use it.
  * Else if the list has exactly one Story and the user gave no other hint: ask the user to confirm it, and STOP.
  * Otherwise (no open Story, or several): ask the user which Story, and STOP.
* If something that worked and broke: `Bug`
* If research for one question: `Spike`
* Otherwise: ask the user and STOP. Never use `Feature`.

## Step 2: Write title and body

* Title: imperative, sentence case, ≤ 60 chars, no ID, no type — `Set up db`
* Body: `<sdlc>/template/issue.tpl`, written to a file; keep the sections that fit the type. No Task list in a Story, no parent line in a Task — GitHub shows both.

## Step 3: Create

```bash
gh issue create --title "<title>" --body-file <file> --type <Type>                    # Story, Bug, Spike
gh issue create --title "<title>" --body-file <file> --type Task --parent <story>      # Task
```

* If `gh` rejects `--type` (older version): create without it, then `gh api -X PATCH repos/{owner}/{repo}/issues/<n> -f type=<Type>`. Otherwise: go to Step 4.

## Step 4: Priority

* If the user asked for a priority: set it — docs/conventions.md §1. Otherwise: skip.

# Output

Begin with the issue URL. No preamble.
