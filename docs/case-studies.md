# Case Studies — init-agent

> Transferable failures and recoveries worth remembering.

---

## Auto-Orch Lesson: Green Slices Can Hide A Broken Assembly

**Source:** Agent-Orch / Auto-Orch B-series remediation.

### Pattern

A system can pass unit tests, focused slice tests, and per-feature reviews while
the assembled workflow still fails at the real boundary between components.
Auto-Orch's early autonomous-mode slices looked green, but the full
Author-to-Execute path could not complete one real cycle because the seam to
Agent-Orch was not proven with the actual CLI contract.

### Doctrine

- Any subprocess seam needs at least one real-boundary test or smoke.
- Trust files, schemas, exit codes, and validated artifacts over worker prose.
- Add an end-to-end proof for workflows whose value depends on composition.
- Keep seam contracts versioned and machine-checkable when other systems depend
  on them.
