# init-agent - Context

> **Purpose**: Working memory for session continuity.

---

## Snapshot

| Attribute | Value |
|-----------|-------|
| **Phase** | Sprint 8 Complete / Existing-Project Refresh Hardened |
| **Mode** | 3 (Autonomous) |
| **Last Updated** | 2026-03-06T23:17:04Z |

---

## What's Happening Now

### Current Focus
Session wrap-up after landing safe re-run and `--update` behavior for existing init-agent projects.

### Recently Completed (Sprint 8)
- ✅ **Contract-Only Refresh on Existing Projects**: Re-runs against existing init-agent-managed directories now refresh only `AGENTS.md` and `skills/*`
- ✅ **Project Memory Preservation**: `context.md`, `WHERE_AM_I.md`, `result-review.md`, `README.md`, and other project-owned files are preserved on rerun
- ✅ **Safer `--force` Semantics**: `--force` no longer deletes the target directory before writing refreshable files
- ✅ **Scoped `--update`**: `--update` now rewrites only contract files and correctly detects project name/profile from `--dir`
- ✅ **Regression Coverage Added**: Integration tests now verify preservation rules and the `--update --dir` project-name path
- ✅ **Older Project Backfill Fixed**: Existing managed projects now recreate missing stateful docs like `WHERE_AM_I.md` and `result-review.md`
- ✅ **Review Follow-ups Applied**: The `--force` banner now matches real behavior, and the upgrade-path gap found in review was fixed
- ✅ **Sprint Review Artifact Written**: `code-reviews/review-2026-03-06.md` captures the review findings and notes their same-day resolution
- ✅ **Docs Updated**: README, generated profile READMEs, sprint plan, and product-orientation docs now describe the new behavior

### Decisions Locked
| Decision | Rationale | Date |
|----------|-----------|------|
| **Existing managed projects refresh contract files only** | Preserves accumulated project memory while still letting methodology contracts evolve | 2026-03-06 |
| **`--force` is non-destructive for existing projects** | Force should skip prompts, not wipe user-owned project state | 2026-03-06 |
| **`--update` is contract-only and target-dir aware** | Updating from outside the project should not stamp the wrong project name into refreshed files | 2026-03-06 |

---

## Next Actions Queue

1. **[PLAN]** Decide Sprint 9 scope after backlog review
2. **[CONSIDER]** Add profile-specific command placeholders or defaults for `{{TEST_COMMAND}}`, `{{BUILD_COMMAND}}`, and `{{RUN_COMMAND}}`
3. **[CONSIDER]** Reconcile stale historical sprint sections in `sprint-plan.md` with actual delivered versions

---

## Open Questions / Blockers

- None currently.

---

*This file is updated every session.*
