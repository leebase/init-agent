# init-agent - Context

> **Purpose**: Working memory for session continuity.

---

## Snapshot

| Attribute | Value |
|-----------|-------|
| **Phase** | Sprint 7 Complete / Ready for Sprint 8 |
| **Mode** | 3 (Autonomous) |
| **Last Updated** | 2026-03-05T23:50:00Z |

---

## What's Happening Now

### Current Focus
Session Wrap-up. Sprint 7 complete.

### Recently Completed (Sprint 7)
- ✅ **AgentFlow Skills Decomposition**: Rewrote `templates/common/agent.md` as slim router (~140 lines → focused contract)
- ✅ **4 High-Quality Skill Files**: Created `skills/development-loop.md`, `skills/test-as-lee.md`, `skills/documentation.md`, `skills/backlog.md` — opinionated, with examples and anti-patterns, not just outlines
- ✅ **Zig Implementation**: Updated `main.zig` with `@embedFile` for all 4 skills, added to all 3 profile definitions, `skills/` directory created on scaffold
- ✅ **--update Compatible**: Skill files treated as contract files — overwritten on `--update`, new `skills/` directory created automatically in old projects
- ✅ **Dogfooded**: Project root `AGENTS.md` and `skills/` updated to new format
- ✅ **Fixed 2 Runaway Process Bugs**: `promptFileAction()` and `--interactive` profile prompt both spun forever on stdin EOF; now exit gracefully — was likely cause of runaway instances on Mac Mini
- ✅ **Fixed 3 Zig 0.13.0 Compat Issues**: `ArrayList.init`, `.deinit()`, `.append()`, `.toOwnedSlice()` all fixed to 0.13.0 API

### Decisions Locked
| Decision | Rationale | Date |
|----------|-----------|------|
| **Trigger-based skill loading** | Agent.md maps situations to skills explicitly (not "load when relevant") | 2026-03-05 |
| **Skills are contract files** | Overwritten by `--update` like AGENTS.md — keeps methodology upgradeable | 2026-03-05 |
| **No profile-specific skills yet** | Generic skills first; profile-specific (e.g. python-testing.md) is Sprint 8 candidate | 2026-03-05 |
| **EOF exits gracefully** | Interactive prompts now return `.skip` / use default on stdin EOF instead of spinning | 2026-03-05 |

---

## Next Actions Queue

1. **[PLAN]** Sprint 8 Planning — review backlog for next features
2. **[CONSIDER]** Profile-specific skills (e.g. `skills/python-testing.md`) as Sprint 8 candidate
3. **[CONSIDER]** `{{TEST_COMMAND}}` / `{{BUILD_COMMAND}}` / `{{RUN_COMMAND}}` as new template variables for profile-specific skill content

---

## Open Questions / Blockers

- None currently.

---

*This file is updated every session.*
