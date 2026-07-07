# Agent Guide: init-agent

> **For AI agents working on the init-agent project.**
>
> This project uses **AgentFlow** — a documentation-driven methodology for human-AI collaboration.
> Read this file first, then `context.md` for current state.

---

## Why This System Exists

AI agents are stateless. Every new session starts from zero. These project files act as **shared memory** between you, the human, and any other AI that works on this project.

When you update `context.md` at session end, you're writing a handoff note that lets **any LLM** — Claude, ChatGPT, Gemini, Copilot — pick up exactly where you left off. Treat these updates as critical, not clerical.

---

## Startup Protocol

At the start of every session, in order:

1. Read `AGENTS.md` (this file) — guardrails and operating rules
2. Read `context.md` — current state and what to do next
3. Check `result-review.md` — what was recently completed
4. Read `sprint-plan.md` — current sprint tasks and priorities
5. Read `WHERE_AM_I.md` — product-level orientation and milestone state

If your harness supports delegated or sub-agents and you plan to use them,
also read `agents/README.md` before selecting a role brief from `agents/`
when those files exist.

If you were asked to set up, launch, or report on a governed workflow, read
`OPERATE.md` when present. It should be treated as the project-specific runbook
for orchestration, launch, monitor, resume, and reporting steps.

---

## Available Skills

Load the relevant skill file when the trigger applies. Do not try to remember — read the file.

| Trigger | Skill to Load |
|---------|--------------|
| You are implementing a feature or fix | `skills/development-loop.md` |
| You are about to test your work | `skills/test-as-lee.md` |
| You are about to commit | `skills/documentation.md` |
| You are creating a backlog item | `skills/backlog.md` |
| You are closing a sprint or preparing a release | `skills/code-review.md` |
| You are delegating implementation to a worker harness | `skills/delegation.md` |
| You are using Agent-Orch or Auto-Orch, converting a sprint plan to a playbook, or launching a governed workflow | `skills/use-orchestration.md` |

Skills are short, focused, and task-specific. They contain the judgment, not just the steps.

---

## Harness Compatibility

To keep this repo usable across Codex, Claude, Gemini, Copilot, Aider,
Antigravity, and similar coding harnesses, treat the project docs as portable
instructions rather than runtime-specific config.

- `AGENTS.md` is the source of truth for startup protocol, guardrails, and
  collaboration expectations.
- `skills/*.md` are portable markdown playbooks. Any harness may load and
  follow them when their trigger applies.
- `agents/*.md` are optional role briefs for harnesses that support delegated
  agents or task-specialized sub-agents.
- If a harness does not support explicit sub-agents, the main agent should read
  the relevant file in `agents/` and apply it directly.
- Keep these files plain markdown and relative-path based. Do not rely on
  proprietary tool names, model names, or frontmatter fields to make the system
  work.
- When a harness-specific wrapper is useful, it must be optional. The markdown
  content still needs to be understandable and executable without that wrapper.

---

## Task Rehydration

**Before continuing any task mid-session:**

1. Re-read `sprint-plan.md`
2. Re-read any files you modified previously in this session
3. Confirm the objective — proceed only when you are oriented

Agents drift. This rule prevents it.

---

## Autonomy Modes

The `Mode` field in `context.md` controls how independently you work:

| Mode | Name | Behavior |
|------|------|----------|
| **1** | Supervised | Ask before every significant action. Explain plan, wait for approval. |
| **2** | Collaborative | Plan approach, implement with check-ins. Ask for approval on decisions, not on routine code. |
| **3** | Autonomous | Execute independently within guardrails. Report results. Only ask if blocked or decision has major consequences. |

**Default is Mode 2.** The human may change the mode in `context.md` at any time.

---

## Guardrails

### ✅ Allowed

- Write and modify code for init-agent
- Create and update documentation
- Add tests for new functionality
- Research solutions to technical problems
- Update context and decision logs
- Create backlog items in `backlog/candidates/`

### ❌ Not Allowed (Without Explicit Permission)

- Add external runtime dependencies
- Make breaking changes to existing APIs or CLI flags
- Delete files without confirming necessity
- Skip tests or documentation updates
- Commit directly to protected branches
- Move files out of `backlog/candidates/` (human curates)

### Subprocess Seam Rule

Any change that touches a subprocess seam — code that invokes another process's
CLI, external worker, model harness, build tool, deployment command, or
orchestrator — must include at least one test or smoke check that invokes the
real boundary. Mocks can support internal unit tests, but they cannot be the
only proof that the assembled system works.

This rule exists because Auto-Orch proved a failure mode worth remembering:
every slice can pass in isolation while the composed system fails at the real
CLI seam. Prefer evidence from the real command boundary, captured artifacts,
and exit codes over worker narration.

---

## Tech Stack

- **Language**: Zig 0.13.0
- **Build**: `zig build` / `zig build test`
- **Templates**: embedded via `@embedFile` at compile time — live in `src/templates/`
- **Human-editable copies**: `templates/` (project root) — must be kept in sync with `src/templates/`
- **Distribution**: cross-compiled binaries, Homebrew formula, curl-install script

> **Key gotcha**: There are TWO template trees. `src/templates/` is what gets compiled in. `templates/` is the human-editable source of truth. When you edit a template, update both.

---

## Document Reference

| File | When to Read | When to Update |
|------|--------------|----------------|
| `AGENTS.md` | Every session start | When conventions change |
| `context.md` | Every session start | Every session end |
| `WHERE_AM_I.md` | Every session start | When milestones reached or direction changes |
| `result-review.md` | Every session start | When work completed |
| `sprint-plan.md` | Every session start | When tasks complete |
| `agents/README.md` | Before using delegated agents | When the delegated-agent workflow changes |
| `agents/*.md` | Before delegating to a specialized role | When the role instructions change |
| `OPERATE.md` | Before running governed workflows | When launch/monitor/resume operations change |
| `sprint-review.md` | After sprints | External AI fills in review |
| `project-plan.md` | When direction unclear | Strategic changes only |
| `product-definition.md` | When scope unclear | Product changes only |
| `architecture.md` | When making tech decisions | When decisions are made |
| `feedback.md` | When given feedback | Human adds feedback |
| `docs/case-studies.md` | When a failure pattern feels familiar | Add transferable failures and recoveries |
| `backlog/schema.md` | Creating backlog items | Never (reference) |
| `backlog/template.md` | Creating backlog items | Never (copy-paste) |

---

## Communication Style

- **Concise**: Get to the point quickly
- **Specific**: Include file paths, line numbers, exact commands
- **Actionable**: Provide clear next steps
- **Honest**: Flag concerns or blockers immediately

---

## For Antigravity Agents (Google DeepMind)

If you are an Antigravity agent, map your internal artifacts to this project's documentation system.

### Artifact Mapping

| Internal Artifact | Project Document | Purpose |
|-------------------|------------------|---------|
| `task.md` | `sprint-plan.md` | Track task status. **Read** project plan to populate your checklist. **Update** project plan when tasks complete. |
| `implementation_plan.md` | `architecture.md` / Design Docs | Plan technical changes. If significant, create/update a design doc in the project as well. |
| `walkthrough.md` | `result-review.md` | Log results. **Update** `result-review.md` at the end of your session. |

### Workflow Adjustments

1. **Session Start**: In addition to standard files, read `task.md` (if existing) and sync it with `sprint-plan.md`.
2. **During Work**: Use your internal `task.md` for fine-grained steps, but update `sprint-plan.md` for high-level status.
3. **Session End**: Ensure `context.md` and `result-review.md` are updated.

---

*Last updated: 2026-03-05*
