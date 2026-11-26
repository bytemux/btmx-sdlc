# btmx-sdlc

Agentic SDLC framework for hobby projects: conventions, templates, skills and CI that let agents deliver work as PRs with minimal human attention.

Design draft: [docs/sdlc-draft-1.md](docs/sdlc-draft-1.md).

## Defined

| Area | Where | What |
| --- | --- | --- |
| Conventions | [docs/conventions.md](docs/conventions.md) | Issue types Story, Task, Bug, Spike; branches `<type>/<n>-<slug>`; Conventional Commits; squash-merge PRs; gates |
| CI | [docs/ci.md](docs/ci.md) | `pr-title` check, `release` workflow; actions pinned to SHA, least permissions |
| Versioning | [docs/versioning.md](docs/versioning.md) | SemVer from Conventional Commits, tags `v<x.y.z>`, release on every merge to `main` |
| Init repo | [skills/init-repo](skills/init-repo/SKILL.md) | Sets up a target repo: pre-commit hooks, `AGENTS.md`, workflows, merge settings, ruleset |
| Issue, PR | [skills/issue](skills/issue/SKILL.md), [skills/pr](skills/pr/SKILL.md) | Create an issue with type and parent; open a draft PR with a valid title |
| Templates | [template/](template/) | idea, architecture, issue, spike, PR description, PR report |

This repo describes the rules; it does not follow them yet (see [AGENTS.md](AGENTS.md)).

## Use

Prerequisites: `gh` (logged in), `pre-commit`, issue types Story, Task, Bug and Spike in the GitHub account settings.

Ask the agent to set up a repo with `skill:init-repo`, for example: "init repo `<owner>/<name>` for btmx-sdlc".

## Roadmap

| Priority | Item |
| --- | --- |
| Blocker | Spec method: TDD, BDD or OpenSpec. Defines SPEC format, GLOSSARY and L2 review input |
| Blocker | Component interfaces and the yaml config that assembles the pipeline |
| Major | PR report format |
| Major | Human approval gate for SPEC before Implement |
| Major | L2 conformance review: how an agent checks a diff against SPEC and Story |
| Major | Where the Roadmap lives (GitHub Projects, Milestones or a file) |
| Minor | Unattended runs |
| Minor | Alternatives for each component |
| Minor | Metric targets, after 3–5 delivery loops |
