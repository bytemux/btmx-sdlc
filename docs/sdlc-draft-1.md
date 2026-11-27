# btmx-sdlc

Nov 26, 2026 · @Mike

## 1. Purpose

btmx-sdlc — agentic SDLC framework: a set of methodologies, components and constraints for an agentic SDLC, plus a pipeline built on a subset of these components.

### Author Goals

- Develop hobby projects
- Try out team development processes and technologies on them

### Goals

- Minimal user attention on product development
- Development is standardized
- Development does not degrade over time
- The system is declarative, components are replaceable

How to check each goal — see §7 Metrics.

### Scope

Mapped to the classic SDLC phases (Planning → Requirements → Design → Implementation → Testing → Deployment → Maintenance), btmx-sdlc is an Agile model with V-model style verification:

| Classic phase | btmx-sdlc | Coverage |
| --- | --- | --- |
| Planning | Discovery: record and review idea, PoC + Roadmap; Update Roadmap | partial |
| Requirements | Story, SPEC with acceptance criteria | covered |
| Design | Spike, ADR; `template/architecture.tpl` is not used by any step yet | partial |
| Implementation | Implement | covered |
| Testing | L1 deterministic, L2 conformance (verification), L3 human (validation) | covered |
| Deployment | release tag on every merge to `main` only | out of scope |
| Maintenance | `Bug` issue type only | out of scope |

### Non-goals

- Deployment: no deploy to environments, no release management beyond the release tag.
- Maintenance: no monitoring, no incident flow, no feedback from production into the Roadmap.

Both may be revisited later.

## 2. Principles

- **Declarative** — the pipeline implementation is defined by a config (yaml) assembled from building blocks: interfaces and components.
- **Replaceable** — component = interface + current implementation. For example, the `quality_gates` category, whose elements any agent can use.
- **Self-verification** — the agent checks the result itself before a human sees it.
- **Human checkpoints** — human attention is needed only at fixed points of the pipeline.

## 3. Pipeline

In short: the user describes an idea → the agent builds it and checks the result against the standards itself → the user reads a PR with a standardized report

### Discovery

Once per project: from idea to approved PoC.

| # | Phase | Attention split | Input | Output | Gate |
| --- | --- | --- | --- | --- | --- |
| 0 | Record idea | human | free-form idea or interview (try `/wayfinder`) | free-form idea record | - |
| 1 | Review idea | human + agent | free-form idea record | analogues, expected UX, critique, PoC + high-level Roadmap | Matches requirements from idea_template.md |
| 2 | Review PoC | human | PoC + Roadmap | approved PoC | - |

### Delivery loop

Repeats for each Story: the first loop implements the PoC, then follows the Roadmap. A fail on L1 or L2 returns to the Implement step; feedback on L3 does too.

| # | Step | Attention split | Input | Output | Gate |
| --- | --- | --- | --- | --- | --- |
| 1 | Pick Story | human | Roadmap | Story issue | Issue template |
| 2 | Spike, if needed | agent | unknowns in the Story | spike report (+ ADR, if needed) | - |
| 3 | Spec | agent | Story | SPEC: goal, out of scope, acceptance criteria | ? |
| 4 | Implement | agent | SPEC | code in a worktree | - |
| 5 | Review: Deterministic | agent | code | green checks | L1 deterministic |
| 6 | Review: Conformance | agent | diff + SPEC + Story | review notes | L2 conformance |
| 7 | PR + report | agent | diff + review notes | PR with report | PR report template |
| 8 | Review: Human | human | PR + report | merge or feedback | L3 human |
| 9 | Update Roadmap | human + agent | merged PR, remarks | updated Roadmap | - |

### Issue types

The main unit of the delivery loop is the Story. A Spike removes unknowns before a Story; Tasks are the agent's steps inside a Story.

| Type | What it is | Output | Code | Done |
| --- | --- | --- | --- | --- |
| Story (main) | vertical slice: "as a user I can X"; 1 Story = 1 PR | working feature in a PR | kept | acceptance criteria met, gates L1–L3 |
| Spike (research) | research of the riskiest assumption before a Story | spike report (+ ADR, if needed) | thrown away | spike report filled in |
| Task | technical step inside a Story; not created in the tracker | part of its Story's PR | kept | closed together with the Story |

## 4. Artifacts (contracts)

Agents and the human communicate through these files, so each one needs a fixed format.

| Artifact | Purpose | Who writes | Who reads | Template |
| --- | --- | --- | --- | --- |
| `GLOSSARY.md` | shared project terms | ? | all agents | ? |
| `SPEC.md` | what we build, acceptance criteria | ? | executor agent, L2 review | ? |
| `docs/adr/0001-slug.md` | decisions that are hard to reverse | ? | all agents | ? |
| `docs/spikes/0001-slug.md` | spike report: question, what was tried, answer, recommendation | agent | HUMAN, agent at the Spec step | `template/spike.tpl` |
| Issue template | one task = one PR | ? | executor agent | `template/issue.tpl` |
| PR report template | standardized agent comment on the results | agent | HUMAN | ? |

- [ ] Open question: what goes into the PR report (gates, deviations from SPEC, what to check by hand)?
- [ ] Decision tracking - ADR? Spec? glossary? All items except ADR are open and depend on the development method chosen from the candidates: TDD, BDD, Openspec

## 5. Components

Each component is described by an interface so that the implementation can be replaced.

### 5.1 Orchestration

| Role | Interface | Current choice | Alternatives |
| --- | --- | --- | --- |
| Idea interview | ? | `/wayfinder` (to try) | ? |
| Agent runtime | ? | Claude Code, CODEX subagent, Antigravity subagent | ? |
| Unattended runs | ? | ? | ? |

### 5.2 Environment (DevEx)

Technology stack by the current development standard; the goal is parallel development.

- devcontainers
- git worktrees

### 5.3 Quality gates

Constraints and checks so that agents give a predictable result that is easy to analyze. Interface: command → pass/fail + report.

| Level | What it checks | Implementations |
| --- | --- | --- |
| L1 deterministic | green checks | types, lint, tests, coverage, mutation testing, fuzzing |
| L2 conformance | conformance to SPEC and the original task in the tracker | ? (reviewer agent) |
| L3 human | final decision | HUMAN review PR |

#### Testing

Testing types inside L1 deterministic:

- Coverage tests
- Mutation testing
- Fuzzing

### 5.4 Tracking

| Role | Interface | Current choice | Alternatives |
| --- | --- | --- | --- |
| Issues, PRs, Roadmap | ? | ? | ? |

### 5.5 Knowledge

| Role | Interface | Current choice | Alternatives |
| --- | --- | --- | --- |
| Rules for agents | ? | `CLAUDE.md` / `AGENTS.md` | ? |
| Skills | ? | harness/skills | ? |

## 6. Bootstrap

A new project starts from a template repo in which the §5 components are already connected.

- [ ] Open question: where does the template live and which components are on by default? - in ./template. A separate skill will initialize the repo, see the ./skills/init folder

## 7. Metrics

Each goal from §1 gets a measurable metric. The values are proposals and need approval.

| Goal | Metric | Data source | Target |
| --- | --- | --- | --- |
| Minimal user attention | human touches per PR; review time | GitHub API: reviews, comments and commits from the human in the PR; `createdAt` → `mergedAt` (`gh pr list --json`) | ? |
| Development does not degrade | % of PRs that pass gates on the first attempt; flaky tests; growth of lint warnings | GitHub Actions: history of runs and attempts (`gh run list`); test reports (JUnit) and lint output as CI artifacts | ? |
| Development is standardized | % of projects from the template; % of PRs with a report from the template | list of repos + template marker file (`gh repo list`); PR body contains the report sections (`gh pr list --json body`) | ? |
| Throughput | issues → merged PRs per week | GitHub API (`gh pr list --state merged --json mergedAt`) or locally `git log --merges --since` | ? |

## 8. Open questions / Backlog

- [x] Non-goals (§1): Deployment and Maintenance
- [ ] Gates for the Idea and Review phases (§3)
- [ ] PR report format (§4)
- [ ] Interfaces for components (§5)
- [ ] Implementation of the L2 conformance review (§5.3)
- [ ] Tracker for issues and Roadmap (§5.4)
- [ ] Template repo (§6)
- [ ] Targets for metrics (§7)
