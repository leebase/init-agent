# init-agent Result Review

> **Running log of completed work.** Newest entries at the top.
>
> Each entry documents what was built, why it matters, and how to verify it works.

---

## 2026-03-06 — Existing-project refresh now preserves project memory

### What Was Built

`init-agent` now treats existing init-agent-managed directories as contract refreshes instead of full rewrites. Re-runs refresh only `AGENTS.md` and `skills/*`, while preserving living project-memory and project-owned files such as `context.md`, `WHERE_AM_I.md`, `result-review.md`, and `README.md`.

`--update` was tightened to the same contract-only scope and fixed to detect project name/profile from `--dir` instead of the caller's current working directory. `--force` no longer deletes the target directory before writing refreshable files.

Follow-up review fixes were also applied: existing managed projects now backfill missing stateful docs instead of skipping them forever, and the `--force` mode label now reflects that it overwrites only refreshable files.

### Why It Matters

This removes the main footgun in the tool's update path: re-running init-agent on an active project no longer risks wiping the handoff notes and state that make AgentFlow usable. It also makes contract refreshes predictable whether they are run inside the project or pointed at it via `--dir`.

### How to Verify

```bash
zig build -Doptimize=ReleaseFast
zig build test
bash tests/integration.sh

# Manual overwrite-path smoke test
tmpdir=$(mktemp -d -t init-agent-manual-XXXXXX)
./zig-out/bin/init-agent demo --profile python --dir "$tmpdir/project" --no-git
printf 'OLD AGENT\n' > "$tmpdir/project/AGENTS.md"
printf 'KEEP CONTEXT\n' > "$tmpdir/project/context.md"
printf 'o\n' | ./zig-out/bin/init-agent demo --profile python --dir "$tmpdir/project" --no-git
grep -q "Agent Guide: demo" "$tmpdir/project/AGENTS.md"
grep -q "KEEP CONTEXT" "$tmpdir/project/context.md"
rm -rf "$tmpdir"

# Backfill missing stateful docs in an older managed project
tmpdir=$(mktemp -d -t init-agent-backfill-XXXXXX)
./zig-out/bin/init-agent demo --profile python --dir "$tmpdir/project" --no-git
rm "$tmpdir/project/WHERE_AM_I.md" "$tmpdir/project/result-review.md"
./zig-out/bin/init-agent demo --profile python --dir "$tmpdir/project" --no-git
test -f "$tmpdir/project/WHERE_AM_I.md"
test -f "$tmpdir/project/result-review.md"
rm -rf "$tmpdir"
```

## 2026-02-17 — Project Scaffolded

**Project initialized** with init-agent.

### Created

| File | Purpose |
|------|---------|
| `AGENTS.md` | AI agent guide and conventions |
| `WHERE_AM_I.md` | Quick orientation for agents |
| `feedback.md` | Human feedback capture |
| `README.md` | Project documentation |
| `context.md` | Session working memory |
| `result-review.md` | This file - running log |
| `sprint-plan.md` | Sprint tracking |

### How to Verify

1. Check all files exist: `ls *.md`
2. Read AGENTS.md to understand project conventions
3. Check context.md for current state

---

*Add new entries above this line. Keep the newest work at the top.*
