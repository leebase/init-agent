# WHERE_AM_I — init-agent

> **Product-level orientation.** Where does this project stand against its goals?
>
> This file tracks progress toward the product vision. For session-level context (what was I working on?), see `context.md`.

---

## Project Health

| Attribute | Value |
|-----------|-------|
| **Project** | init-agent |
| **Profile** | Zig CLI Tool |
| **Current Phase** | Phase 2 — Safety, Upgradeability, and Distribution |
| **Overall Status** | 🟢 Active development |
| **Last Updated** | 2026-03-06 |

---

## Progress Against Product Goals

> Reference: `product-definition.md` for full success criteria.

### MVP Criteria

| Criterion | Status | Notes |
|-----------|--------|-------|
| Scaffold projects with AgentFlow files | ✅ Done | All profiles generate project memory, backlog, and skills structure |
| Refresh methodology contracts safely | ✅ Done | Existing projects preserve state while refreshing `AGENTS.md` and `skills/*` |
| Basic documentation | ✅ Done | README, templates, and project docs updated |

### Current Phase Goals

| Goal | Status | Notes |
|------|--------|-------|
| Keep existing-project updates safe | ✅ Done | Sprint 8 completed with contract-only refresh rules |
| Maintain release/build quality | ✅ Done | Build, unit tests, integration tests, and template sync passed |
| Prepare next improvement sprint | 🟡 In progress | Backlog review and roadmap cleanup still pending |

---

## Sprint Position

| Sprint | Focus | Status |
|--------|-------|--------|
| Sprint 8 — Safe Existing-Project Refresh | Preserve project memory during reruns and updates | ✅ Complete |

---

## Product Risks & Blockers

| Risk/Blocker | Impact | Status |
|-------------|--------|--------|
| Historical planning docs are stale | Creates confusion about actual completed work | 🟡 Cleanup needed |
| Zig 0.13.0 build requirement is not enforced locally | Local builds fail with newer Zig unless the right compiler is used | 🟡 Known issue |

---

## Key Decisions Made

Decisions that affect product direction (for technical decisions, see `architecture.md`):

| Decision | Rationale | Date |
|----------|-----------|------|
| Existing managed projects refresh contract files only | Preserve accumulated project memory while keeping methodology contracts upgradeable | 2026-03-06 |
| `--force` is non-destructive for managed projects | Prompt bypass should not imply deleting user-owned state | 2026-03-06 |

---

## What "Done" Looks Like

> Pull from `product-definition.md` once written. This section answers: "How do we know we've succeeded?"

- [x] Users can scaffold new AgentFlow projects across supported profiles
- [x] Users can refresh contract files in existing projects without overwriting project memory
- [ ] Historical product and sprint docs fully reconciled with delivered work

---

*Update this file when project milestones are reached or product direction changes. This is your compass — `context.md` is your GPS.*
