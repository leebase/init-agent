---
id: BI-002
title: Add explicit Definition of Done checklist template to AGENTS.md

source: external-review
source_insight: >
  The Definition of Done exists implicitly but making it a copy-paste checklist in AGENTS.md makes it portable across any agent.

opportunity: >
  Any AI agent, on any platform, gets a concrete checklist to verify before marking work complete.
  Removes ambiguity about what "done" means. Reduces missed steps when switching LLMs.

why_now: >
  AGENTS.md was just rewritten with AgentFlow branding. Adding this while the template is fresh
  ensures it ships with the next --update push to all projects.

minimal_impl: >
  Add a "Done Checklist" section to AGENTS.md with a markdown checkbox template that references:
  current Mode, Test As Lee passed, docs updated (context.md, WHERE_AM_I.md, result-review.md),
  and project-specific verification command(s) (e.g., `zig build test`, `pytest`, `npm test`).
  The checklist should be copy-pasteable into context.md or PR descriptions.

definition_of_done:
  - AGENTS.md contains a Done Checklist section with markdown checkboxes
  - Checklist references Mode, Test As Lee, doc updates, and verification commands
  - Checklist uses {{PROFILE}}-appropriate verification commands
  - Updated via --update to all existing projects

effort: S
build_recipe: builder_safe
priority: next

tags:
  - template
  - agents-md
  - definition-of-done

status: candidate
created_at: 2026-02-19T17:45:00Z
created_by: antigravity
token_cost: 0

approved_at: ~
approved_by: ~
notes: ~

implemented_at: ~
implemented_by: ~
pr_url: ~
---

# Additional Context

Current AGENTS.md already has a Definition of Done section with checkboxes, but it's generic:
```
- [ ] Code works (tests pass, app runs)
- [ ] Tested As Lee (no obvious issues a user would hit)
- [ ] Documentation updated (context.md, WHERE_AM_I.md, etc.)
- [ ] Human can pick up where you left off (context is clear)
- [ ] Changes committed and pushed
```

The improvement would make it more actionable by adding:
- Current Autonomy Mode acknowledged
- Specific verification command(s) per profile
- Explicit list of which docs were touched

Example enhanced checklist:
```
## Done Checklist (copy to context.md when completing work)
- [ ] Mode {{MODE}}: worked within autonomy boundaries
- [ ] `{{VERIFY_CMD}}` passes clean
- [ ] Tested As Lee: ran the app as a user, fixed all issues
- [ ] Updated: context.md, WHERE_AM_I.md, result-review.md, sprint-plan.md
- [ ] Committed and pushed with descriptive message
```

Where `{{VERIFY_CMD}}` would be profile-specific:
- python: `pytest && ruff check src/`
- web-app: `npm test && npm run build`
- zig-cli: `zig build test`
