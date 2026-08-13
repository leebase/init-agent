# init-agent - Context

> **Purpose**: Working memory for session continuity.

---

## Snapshot

| Attribute | Value |
|-----------|-------|
| **Phase** | AgentFlow Contract Refresh / Existing-Project Refresh Hardened |
| **Mode** | 3 (Autonomous) |
| **Last Updated** | 2026-07-07 |

---

## What's Happening Now

### Current Focus
Session wrap-up after refreshing init-agent's AgentFlow docs from the evolved
`agent-orch` / `auto-orch` operating doctrine and recompiling the executable.

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

### Recently Completed (2026-07-07)
- ✅ **Agent-Orch/Auto-Orch Doctrine Ported**: Root and generated `AGENTS.md` now include `WHERE_AM_I.md` startup, harness portability, optional governed-workflow runbook handling, and the subprocess seam rule
- ✅ **New Common Skills Added**: Generated projects now include `skills/delegation.md` and `skills/use-orchestration.md`
- ✅ **Case Study Memory Added**: Root and generated projects now include `docs/case-studies.md` seeded with the Auto-Orch "green slices can hide a broken assembly" lesson
- ✅ **Template Registry Wired**: All current profiles emit the new common docs/skills, and `templates/` matches `src/templates/`
- ✅ **Executable Recompiled**: `zig-out/bin/init-agent` was rebuilt via direct Zig 0.13.0 compile path because `zig build` is blocked locally by macOS SDK/toolchain drift
- ✅ **Git Worktree Cleanup**: Old sync-conflict artifacts, stale dist archives, and smoke-worktree clutter were removed before commit

### Decisions Locked
| Decision | Rationale | Date |
|----------|-----------|------|
| **Existing managed projects refresh contract files only** | Preserves accumulated project memory while still letting methodology contracts evolve | 2026-03-06 |
| **`--force` is non-destructive for existing projects** | Force should skip prompts, not wipe user-owned project state | 2026-03-06 |
| **`--update` is contract-only and target-dir aware** | Updating from outside the project should not stamp the wrong project name into refreshed files | 2026-03-06 |
| **Generated contracts require real-boundary proof for subprocess seams** | Auto-Orch showed that mock-only seam tests can leave the assembled system broken despite green slices | 2026-07-07 |

---

## Next Actions Queue

1. **[PLAN]** Decide Sprint 9 scope after backlog review
2. **[CONSIDER]** Add profile-specific command placeholders or defaults for `{{TEST_COMMAND}}`, `{{BUILD_COMMAND}}`, and `{{RUN_COMMAND}}`
3. **[CONSIDER]** Reconcile stale historical sprint sections in `sprint-plan.md` with actual delivered versions

---

## Open Questions / Blockers

- `zig build` fails with Homebrew Zig 0.15.2 because `build.zig` uses the Zig
  0.13 API. Official Zig 0.13.0 also fails to link its build runner against
  this host's newer macOS SDK. Workaround used successfully: compile/test
  `src/main.zig` directly with `/tmp/zig-macos-aarch64-0.13.0/zig` and a tiny
  temporary `build_options` module.
- `make check-sync` passes after removing old `*.sync-conflict-*` files.

---

*This file is updated every session.*
