# Skill: Backlog Management

> Load this skill when creating, reviewing, or triaging backlog items for init-agent.

---

## The Backlog System

```
backlog/
  candidates/    ← AI writes here. Human reviews.
  approved/      ← Human moves items here. AI implements.
  parked/        ← Human moves here. Deferred indefinitely.
  implemented/   ← Builder moves here on completion.
```

Only the human moves items between folders (except `implemented/` — builder moves there when done).

---

## How to Create a Backlog Item

Copy `backlog/template.md` to `backlog/candidates/BI-NNN-kebab-title.md`.

**Naming:** `BI-004-add-rust-profile.md`

---

## Scope Rules for init-agent

A backlog item is right-sized if it can be implemented in one sprint session without unexpected scope creep. Common pitfalls:

**Too large:**
- "Add TypeScript support" (profile + templates + tests + docs = multiple sessions)

**Right-sized:**
- "Add TypeScript profile with package.json and tsconfig.json templates"
- "Add {{TEST_COMMAND}} as a substitution variable for python profile"
- "Fix --list output to show skill file count per profile"

---

## Good Acceptance Criteria for init-agent

Frame criteria as verifiable checks:

**Bad:**
- Output looks better
- Error handling improved

**Good:**
- Running `init-agent test --profile python` creates `test/skills/` with 5 `.md` files
- Running `init-agent --list` shows all profiles with their descriptions
- Running `init-agent test --profile nonexistent` prints "Error: Unknown profile" and exits with code 1

---

## When to Create vs. Just Do It

**Just do it:**
- Bug fix discovered during implementation of an approved item
- Documentation update that's clearly within current sprint scope
- Work taking < 30 min that's obviously correct

**Create a backlog item:**
- New feature idea that surfaced mid-sprint
- Change to the public CLI interface (flags, output format)
- Something requiring Lee's explicit prioritization decision

---

## Moving to Implemented

When an approved item is complete:

1. Move from `backlog/approved/` to `backlog/implemented/`
2. Add at the bottom:

```markdown
## Completion

**Completed:** 2026-MM-DD
**Commit:** [hash]
**Verification:** `./zig-out/bin/init-agent test --profile python --force && ls test/skills/`
```

*Last updated: 2026-03-05*
