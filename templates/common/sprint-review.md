# {{PROJECT_NAME}} Sprint Review

> **External AI Review.** Hand sprint results to a fresh AI for outside perspective.
>
> Use this when you want an unbiased assessment of what was built. The reviewing AI
> wasn't involved in the work, so it catches things the builder AI missed.

---

## How to Use This File

### As the Human

1. At the end of a sprint (or whenever you want a second opinion):
   - Open a **new conversation** with any AI
   - Share the sprint results, relevant code, and this file
   - Ask it to review and document findings below

2. The reviewing AI fills in a new entry at the top (newest first)

3. You decide what to action, park, or decline

### Why a Fresh AI?

The AI that built the code is biased by its own reasoning. A fresh AI will:
- Question assumptions the builder took for granted
- Spot patterns the builder was too close to see
- Evaluate quality without sunk-cost attachment

---

## Reviews (Newest First)

### Sprint {{NUMBER}} — Review by {{REVIEWER}}

**Date**: {{DATE}}
**Status**: 🟡 Pending / 🟢 Actioned / 🔴 Declined

**What Was Delivered**:

| Feature | Notes |
|---------|-------|
| Feature 1 | Description |

**Findings**:

1. **[CATEGORY] Brief description**
   - **Issue**: What was found
   - **Recommendation**: What should change
   - **Priority**: 🔴 High / 🟡 Medium / 🟢 Low

**Action Items**:
- [ ] Item 1
- [ ] Item 2

**Overall Assessment**:
[Reviewer's summary: What's strong? What needs attention? Is the project on track?]

---

## Review Categories

- **[ARCHITECTURE]** — Structural decisions, patterns
- **[CODE]** — Implementation quality, logic
- **[SCOPE]** — Is the work aligned with product goals?
- **[TEST]** — Coverage, quality, edge cases
- **[DOCS]** — Documentation completeness
- **[UX]** — User experience, usability
- **[RISK]** — Technical debt, security, scalability

## Status Legend

- 🟡 **Pending** — Feedback received, not yet actioned
- 🟢 **Actioned** — Changes implemented
- 🔴 **Declined** — Intentionally not addressed (include rationale)

---

*This file is for external review. The reviewer should be a fresh AI that wasn't involved in building.*
