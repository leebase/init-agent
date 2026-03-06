# Architecture Notes

---

## 2026-03-06 — Separate contract refresh from project state

**Decision:** Existing init-agent-managed projects refresh only contract files (`AGENTS.md` and `skills/*`) on rerun and via `--update`. Living project-memory and project-owned files such as `context.md`, `WHERE_AM_I.md`, `result-review.md`, `README.md`, and profile source files are preserved.

**Rationale:** The AgentFlow model depends on those files accumulating project-specific state over time. Rewriting them from templates during a rerun destroys the handoff context that the tool exists to create. Contract files are different: they define methodology behavior and should remain upgradeable.

**Alternatives rejected:** Continue treating every template file the same on rerun. That kept the implementation simpler, but it made re-running the tool unsafe for active projects and turned `--force` into a destructive footgun.

**Consequences:** The scaffold path now distinguishes between new/unmanaged directories and existing init-agent-managed projects. `--force` skips prompts for refreshable files but does not delete the target directory, and `--update` is intentionally limited to contract files.
