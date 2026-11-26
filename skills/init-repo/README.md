# skill:init-repo

Set up a repo for the btmx-sdlc workflow (docs/conventions.md).

Run against an empty repo, or name a repo to create.
Requires a decision on the stack: which CI, which task tracker, which languages.
Default: GitHub, GitHub, Python.

## Steps

1. Copy `config/.pre-commit-config.yaml` to the repo root and run `pre-commit install`.
2. Add `config/AGENTS.md` to the repo's `AGENTS.md`.
3. Set merge settings (squash only, PR title as commit, delete branch on merge) — see docs/conventions.md §5.
4. Ruleset on `main` — only for a public repo or with GitHub Pro.
