---
# Backlog Item Template
# Copy this file to backlog/candidates/BI-NNN-{kebab-title}.md
# Then fill in all REQUIRED fields (marked with ✅)

id: BI-003                              # ✅ REQUIRED: Next sequential number
title: Antigravity Agent Integration    # ✅ REQUIRED: Max 80 chars

source: analysis/antigravity            # ✅ REQUIRED: What inspired this
source_insight: >                       # ✅ REQUIRED: One sentence key insight
  Antigravity agents use internal artifacts (`task.md`, `implementation_plan.md`) that map directly to AgentFlow documents (`sprint-plan.md`, `architecture.md`).

opportunity: >                          # ✅ REQUIRED: What capability is gained
  Enables Antigravity agents (Google DeepMind) to contribute to `init-agent` projects with full context preservation and zero friction.

why_now: >                              # ✅ REQUIRED: Why this matters now
  Antigravity agents are active on the project and need a formalized workflow.

minimal_impl: >                         # ✅ REQUIRED: TinyClaw version
  Update `AGENTS.md` to include a specific section for Antigravity agents, defining the artifact mapping protocol:
  - `task.md` <-> `sprint-plan.md` / `context.md`
  - `implementation_plan.md` <-> `architecture.md` / design docs
  - `walkthrough.md` <-> `result-review.md`

definition_of_done:                     # ✅ REQUIRED: Checklist of outcomes
  - `AGENTS.md` updated with Antigravity-specific guidelines
  - Workflow verified by completing a task using the new protocol
  - `context.md` reflects successful integration

effort: S                               # ✅ REQUIRED: S (hours) | M (days) | L (weeks)
build_recipe: builder_safe              # ✅ REQUIRED: planner_only | builder_safe | operator_blocked
priority: now                           # ✅ REQUIRED: now | next | someday

# Optional but recommended
dependencies: []

risks: >
  None. This is a documentation enhancement.

mitigations: >
  N/A

tags:
  - documentation
  - workflow
  - agent-integration

# RUNTIME FIELDS (AI populates these)
status: candidate
created_at: 2026-02-19T23:05:00Z
created_by: Antigravity-Agent
token_cost: 0

# CURATOR FIELDS (Human populates when approving)
approved_at: ~
approved_by: ~
notes: ~

# BUILDER FIELDS (Factory populates when implementing)
implemented_at: ~
implemented_by: ~
pr_url: ~
---
