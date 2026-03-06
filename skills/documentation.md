# Skill: Documentation Update

> Load this skill after tests pass, before committing.

---

## Files to Update and When

| File | Update when... | Notes |
|------|----------------|-------|
| `context.md` | Every session end | Current state, next actions, decisions locked |
| `result-review.md` | Something meaningful was built | Full entry at the TOP |
| `sprint-plan.md` | Tasks complete or status changes | Mark done, update notes |
| `WHERE_AM_I.md` | Sprint boundary or major pivot | Phase, sprint position |
| `architecture.md` | A technical decision was made | Decision + rationale + alternatives rejected |
| `README.md` | CLI interface or flags changed | Usage examples, new flags |
| `AGENTS.md` | Conventions or guardrails changed | This file |
| `skills/*.md` | A skill's content is stale | These files |

---

## Template Sync (init-agent specific)

If you modified any skill or template, confirm both copies are in sync:

```bash
diff templates/common/agent.md src/templates/common/agent.md
diff templates/common/skills/development-loop.md src/templates/common/skills/development-loop.md
# etc. for any file you touched
```

If they differ — sync `src/templates/` from `templates/` before committing.

---

## How to Write a Good `context.md` Update

**Bad:**
```
Working on sprint 8 stuff. Some things done.
```

**Good:**
```
## What's Happening Now

### Current Focus
Added profile-specific skill variables to all 3 profiles.

### Recently Completed
- ✅ Added {{TEST_COMMAND}} substitution for python profile
- ✅ All 18 integration tests pass
- ✅ Smoke tested --profile python, web-app, zig-cli

### Decisions Locked
| Decision | Rationale | Date |
|---|---|---|
| TEST_COMMAND per profile | Avoids generic placeholder in skills | 2026-03-05 |

### Next Actions Queue
1. [TEST] Run integration.sh on all platforms
2. [DOCS] Update README with new skill variables
```

The test: could an agent with zero prior context read this and know exactly what to do next?

---

## How to Write a Good `result-review.md` Entry

Add at the **top**. Structure:

```markdown
## YYYY-MM-DD — [Short description]

### What Was Built
[1–3 sentences. What exists now that didn't before.]

### Why It Matters
[What problem this solves or enables.]

### How to Verify
\`\`\`bash
/home/lee/zig/zig build -Doptimize=ReleaseFast
./zig-out/bin/init-agent test-proj --profile python --force
ls test-proj/skills/
rm -rf test-proj
\`\`\`
```

---

## Commit Message Format

```bash
git add -A -- ':!tmp-init-agent-smoke' ':!dist/*.tar.gz'
git commit -m "feat: short description of what changed"
```

**Good:** `feat: add code-review skill to all profiles with code-reviews/ scaffold dir`
**Bad:** `update`, `wip`, `more changes`

*Last updated: 2026-03-05*
