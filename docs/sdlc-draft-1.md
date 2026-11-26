# btmx-sdlc

Nov 26, 2026 · @Mike

## 1. Purpose

btmx-sdlc — agentic SDLC framework: набор методологий, компонентов и constraints для агентского SDLC, плюс pipeline на подмножестве этих компонентов.

### Author Goals

- Разработка хобби-проектов
- Обкатка процессов и технологий командной разработки на их примере

### Goals

- Минимум внимания пользователя на разработку продукта
- Разработка стандартизирована
- Разработка не деградирует со временем
- Система declarative, компоненты replaceable

Как проверять каждую цель — см. §7 Metrics.

## 2. Principles

- **Declarative** — pipeline implementation задаётся config (yaml), собранным из кубиков: interfaces и components.
- **Replaceable** — компонент = interface + текущая implementation. Например, категория `quality_gates`, к элементам которой может обращаться любой агент.
- **Self-verification** — агент сам проверяет результат до того, как его увидит человек.
- **Human checkpoints** — внимание человека нужно только в фиксированных точках pipeline.

## 3. Pipeline

Коротко: пользователь рассказывает идею → агент делает и сам проверяет результат по стандартам → пользователь читает PR со стандартизированным report

### Discovery

Один раз на проект: от идеи до утверждённого PoC.

| # | Phase | Attention split | Input | Output | Gate |
| --- | --- | --- | --- | --- | --- |
| 0 | Record idea | human | идея в свободной форме или интервью (попробовать `/wayfinder`) | запись идеи в свободной форме | - |
| 1 | Review idea | human + agent | запись идеи в свободной форме | аналоги, ожидаемый UX, критика, PoC + укрупненный Roadmap | Matches requirements from idea_template.md |
| 2 | Review PoC | human | PoC + Roadmap | утверждённый PoC | - |

### Delivery loop

Повторяется на каждую Story: первый loop — реализация PoC, дальше по Roadmap. Fail на L1 или L2 возвращает к шагу Implement, feedback на L3 — тоже.

| # | Step | Attention split | Input | Output | Gate |
| --- | --- | --- | --- | --- | --- |
| 1 | Pick Story | human | Roadmap | Story issue | Issue template |
| 2 | Spike, если нужен | agent | неизвестность в Story | spike report (+ ADR, если нужно) | - |
| 3 | Spec | agent | Story | SPEC: goal, out of scope, acceptance criteria | ? |
| 4 | Implement | agent | SPEC | код в worktree | - |
| 5 | Review: Deterministic | agent | код | green checks | L1 deterministic |
| 6 | Review: Conformance | agent | diff + SPEC + Story | review notes | L2 conformance |
| 7 | PR + report | agent | diff + review notes | PR с report | PR report template |
| 8 | Review: Human | human | PR + report | merge или feedback | L3 human |
| 9 | Update Roadmap | human + agent | merged PR, замечания | обновлённый Roadmap | - |

### Issue types

Основная единица delivery loop — Story. Spike снимает неизвестность перед Story, Task — шаги агента внутри Story.

| Type | Что это | Output | Код | Done |
| --- | --- | --- | --- | --- |
| Story (main) | vertical slice: «я как пользователь могу X»; 1 Story = 1 PR | работающая фича в PR | остаётся | acceptance criteria выполнены, gates L1–L3 |
| Spike (research) | исследование riskiest assumption перед Story | spike report (+ ADR, если нужно) | выбрасывается | spike report заполнен |
| Task | технический шаг внутри Story; не заводится в tracker | часть PR своей Story | остаётся | закрывается вместе со Story |

## 4. Artifacts (contracts)

Агенты и человек общаются через эти файлы, поэтому у каждого нужен фиксированный формат.

| Artifact | Назначение | Кто пишет | Кто читает | Template |
| --- | --- | --- | --- | --- |
| `GLOSSARY.md` | единые термины проекта | ? | все агенты | ? |
| `SPEC.md` | что строим, acceptance criteria | ? | агент-исполнитель, L2 review | ? |
| `docs/adr/0001-slug.md` | решения, которые трудно отменить | ? | все агенты | ? |
| `docs/spikes/0001-slug.md` | spike report: question, what was tried, answer, recommendation | агент | HUMAN, агент на шаге Spec | `template/spike.tpl` |
| Issue template | одна задача = один PR | ? | агент-исполнитель | `template/issue.tpl` |
| PR report template | стандартизированный комментарий агента о результатах | агент | HUMAN | ? |

- [ ] Open question: что входит в PR report (gates, отклонения от SPEC, что проверить руками)?
- [ ] Decision tracking - ADR? Spec? glosary? Все пункты кроме ADR под вопросом и зависят от выбранной разработки из кандидатов: TDD, BDD, Openspec

## 5. Components

Каждый компонент описан через interface, чтобы implementation можно было заменить.

### 5.1 Orchestration

| Role | Interface | Current choice | Alternatives |
| --- | --- | --- | --- |
| Interview идеи | ? | `/wayfinder` (попробовать) | ? |
| Agent runtime | ? | Claude Code, CODEX subagent, Antigravity subagent | ? |
| Unattended runs | ? | ? | ? |

### 5.2 Environment (DevEx)

Стек технологий по современному стандарту разработки; цель — многопоточная разработка.

- devcontainers
- git worktrees

### 5.3 Quality gates

Constraints и checks, чтобы агенты давали предсказуемый результат, который легко анализировать. Interface: команда → pass/fail + report.

| Level | Что проверяет | Implementations |
| --- | --- | --- |
| L1 deterministic | зелёные чеки | types, lint, tests, coverage, mutation testing, fuzzing |
| L2 conformance | соответствие SPEC и исходной задаче в tracker | ? (агент-reviewer) |
| L3 human | финальное решение | HUMAN review PR |

#### Testing

Виды тестирования внутри L1 deterministic:

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
| Правила для агентов | ? | `CLAUDE.md` / `AGENTS.md` | ? |
| Skills | ? | harness/skills | ? |

## 6. Bootstrap

Новый проект стартует из template repo, в котором компоненты §5 уже подключены.

- [ ] Open question: где лежит template и какие компоненты включены по умолчанию? - в ./template. Для инициализации репозитория будет отдельный скилл см папку ./skills/init

## 7. Metrics

Каждая цель из §1 получает измеримую метрику. Значения — предложения, их нужно утвердить.

| Цель | Metric | Data source | Target |
| --- | --- | --- | --- |
| Минимум внимания пользователя | human touches на PR; время review | GitHub API: reviews, comments и commits от human в PR; `createdAt` → `mergedAt` (`gh pr list --json`) | ? |
| Разработка не деградирует | % PR, прошедших gates с первой попытки; flaky tests; рост lint warnings | GitHub Actions: история runs и attempts (`gh run list`); test reports (JUnit) и lint output как CI artifacts | ? |
| Разработка стандартизирована | % проектов из template; % PR с report по template | список repos + marker-файл template (`gh repo list`); PR body содержит секции report (`gh pr list --json body`) | ? |
| Throughput | issues → merged PR за неделю | GitHub API (`gh pr list --state merged --json mergedAt`) или локально `git log --merges --since` | ? |

## 8. Open questions / Backlog

- [ ] Non-goals (§1)
- [ ] Gates для фаз Idea и Review (§3)
- [ ] Формат PR report (§4)
- [ ] Interfaces для компонентов (§5)
- [ ] Реализация L2 conformance review (§5.3)
- [ ] Tracker для issues и Roadmap (§5.4)
- [ ] Template repo (§6)
- [ ] Targets для metrics (§7)
