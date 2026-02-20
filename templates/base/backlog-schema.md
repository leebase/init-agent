# Backlog Item Schema

## File Location

```
backlog/
├── candidates/       # AI writes here
├── approved/         # Human moves here
├── parked/           # Human moves here
├── implemented/      # Completed
└── schema.md         # This file
```

---

## Schema

```yaml
id: BI-001
title: Feature Title
source: research/target
source_insight: One sentence insight
opportunity: What capability we gain
why_now: Why this matters now
minimal_impl: Smallest working version
definition_of_done:
  - Task 1
  - Task 2
effort: S  # S, M, L
symforge_recipe: builder_safe  # planner_only, builder_safe, operator_blocked
priority: now  # now, next, someday
status: candidate  # candidate, approved, parked, implemented
created_at: 2026-02-17T10:00:00Z
created_by: init-agent
```

---

## Workflow

```
AI generates → candidates → Human approves → approved → Complete → implemented
                 ↓
           parked (deferred)
```
