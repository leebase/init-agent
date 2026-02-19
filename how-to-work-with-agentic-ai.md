# How To Work with Agentic AI: The AgentFlow Method

> A practical guide to human-AI collaboration using structured project documentation.
>
> **AgentFlow** is a methodology for working with AI agents across sessions, tools, and LLMs — refined through real-world collaborative development.

---

## The Core Problem

AI agents are stateless. Every time you start a new session — whether it's a new conversation, a different LLM, or picking up after a break — the AI has **zero memory** of what happened before.

**AgentFlow** solves this with **markdown files that act as shared memory** between you and any AI agent. When every session starts by reading the same files and ends by updating them, you get continuity across sessions, across tools, and across LLMs.

---

## The Document System

AgentFlow uses purpose-built markdown files organized into three tiers:

### Stable Documents (rarely change)

These define *what* you're building and *how* you work.

| File | Purpose |
|------|---------|
| `product-definition.md` | Product vision, problem statement, success criteria, constraints |
| `project-plan.md` | Strategic roadmap — phases, objectives, architecture principles |
| `AGENTS.md` | Rules, guardrails, and the Development Loop — the contract between human and AI |
| `architecture.md` | Technical decisions (ADRs), system overview, technology stack |

### Tactical Documents (change per sprint)

These organize *the work.*

| File | Purpose |
|------|---------|
| `sprint-plan.md` | Current sprint tasks, statuses, and version targets |
| `sprint-review.md` | External AI review — hand sprint results to a fresh AI for unbiased feedback |
| `feedback.md` | Structured feedback log — one AI codes, another reviews |
| `backlog/` | Feature pipeline: candidates → approved → parked → implemented |

### Dynamic Documents (change every session)

These are the **heartbeat of AgentFlow.** They answer the two critical questions:

| File | Question | Updated |
|------|----------|---------|
| `context.md` | "What was I working on and what's next?" | Every session end |
| `WHERE_AM_I.md` | "Where does this project stand against its goals?" | When milestones reached |
| `result-review.md` | "What was recently completed and how do I verify it?" | When work completes |

#### `context.md` vs `WHERE_AM_I.md` — They're Different

These two files operate at different altitudes:

- **`context.md`** is **session-level**. It's tactical: what was I doing, what's next, what decisions were made. It's the handoff note so any AI can pick up the work.
- **`WHERE_AM_I.md`** is **product-level**. It's strategic: where does this project stand against its product goals? Are we on track for MVP? Which phase are we in? It's the compass that keeps the project oriented.

Think of it this way: `context.md` is your GPS ("turn left in 200 feet"). `WHERE_AM_I.md` is the map view ("you're 60% of the way there").

---

## The Session Lifecycle

Every AI session follows three phases: **Start → Work → Close.**

### 1. Starting a Session

When you open a new conversation with any AI, give it this prompt:

> **"Read AGENTS.md and context.md to get oriented. Check sprint-plan.md for current tasks. Pick up from the Next Actions Queue."**

The AI goes from blank slate to oriented team member in seconds.

### 2. Working During a Session

The AI follows the **Development Loop** (see next section) for every piece of work. Communication is direct:

| You → AI | AI → You |
|----------|----------|
| "Do X. Constraints: Y. Output to Z." | Specific file paths, exact commands, clear next steps |
| "What's the concern with approach A vs B?" | Honest trade-offs, flagged risks |

### 3. Closing a Session

**This is the most important step.** Before ending:

1. **Update `context.md`** — move completed items, update next actions, lock decisions, refresh timestamp
2. **Update `WHERE_AM_I.md`** — only if project milestones were reached or direction shifted
3. **Update `result-review.md`** — log what was built, why it matters, how to verify
4. **Update `sprint-plan.md`** — mark completed tasks

**Why this matters:** The next session — whether it's you with the same LLM, a different LLM, or someone else entirely — will read these files and know exactly where to start.

---

## The Development Loop

Every piece of work follows this loop. This is the heartbeat of AgentFlow.

```
┌──────────────────────────────────────────────────────────┐
│                   THE DEVELOPMENT LOOP                    │
│                                                          │
│   1. CODE        Write the implementation                │
│        ↓                                                 │
│   2. TEST        Run automated tests (unit, lint, build) │
│        ↓                                                 │
│   3. TEST AS LEE Run the app as the human would use it   │
│        ↓                                                 │
│   4. FIX         Fix anything that broke                 │
│        ↓                                                 │
│   5. LOOP        Repeat 2-4 until everything passes      │
│        ↓                                                 │
│   6. DOCUMENT    Update docs (context, results, sprint)  │
│        ↓                                                 │
│   7. COMMIT      git add, commit, push                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### What "Test As Lee" Means

**Test As Lee** means: run the application the way the human would actually use it, and fix every problem you find.

The goal is that when Lee sits down to test, he can **focus on functionality and product decisions** — not debugging crashes, missing imports, or broken layouts. The AI handles the QA so the human can be the product owner.

Specifically:

1. **Start the app** the way a user would (`npm run dev`, `python main.py`, `zig build run`)
2. **Use every feature you touched** — click buttons, submit forms, navigate pages, run commands
3. **Try the unhappy paths** — bad input, empty fields, missing data, rapid actions
4. **Check for runtime errors** — console errors, stack traces, unhandled exceptions
5. **Verify the UI looks right** (if applicable) — layout, responsiveness, readability
6. **Test the full flow end-to-end** — not just the function you wrote, but the complete feature

If anything fails, go back to CODE and fix it. No exceptions.

### When the Loop Gets Stuck

If the AI can't fix an issue after 3 attempts:

1. **Stop.** Don't keep spinning.
2. **Document the issue** in `context.md` under "Open Questions" or "Blockers"
3. **Note what was tried** and why it failed
4. **Hand it back to the human** — this is what Mode 2 (collaborative) is for

The human's time is better spent on a targeted problem than debugging an AI's rabbit hole.

---

## Switching Between LLMs

Because all state lives in markdown files (not conversation history), you can:

1. **Start a task in Claude**, update `context.md`, end the session
2. **Continue in ChatGPT** — it reads `context.md` and picks up immediately
3. **Get a review in Gemini** — same starting point, fresh perspective
4. **Hand off to a teammate** — they (or their AI) read the same files

The key rule: **always update `context.md` before switching.** It's the handoff document.

---

## Autonomy Modes

The `Mode` field in `context.md` tells the AI how independently to work:

| Mode | Name | When to Use |
|------|------|-------------|
| **1** | Supervised | New project, unfamiliar territory, high-risk changes. AI asks before every significant action. |
| **2** | Collaborative | Most work. AI plans approach and implements, checks in on decisions, reports results. **This is the default.** |
| **3** | Autonomous | Well-defined tasks with clear constraints. AI executes the full Development Loop independently, reports when done. |

You can change the mode anytime by editing `context.md`. The AI should read it at session start and adjust its behavior accordingly.

---

## AGENTS.md — The Contract

`AGENTS.md` is the rules document. It tells every AI agent:

- **What it's allowed to do** — write code, update docs, add tests, create backlog candidates
- **What it's NOT allowed to do** without asking — add dependencies, delete files, make breaking changes
- **The Development Loop** — the exact sequence for every piece of work
- **Communication expectations** — concise, specific, actionable, honest
- **The document protocol** — which files to read/update and when

Think of it as an onboarding doc for a new hire — except the "new hire" shows up every session with amnesia. It needs to be comprehensive enough that any AI, on any platform, can read it and work effectively within 60 seconds.

---

## The Backlog System

For managing feature ideas, AgentFlow uses a structured backlog with human curation:

```
backlog/
├── candidates/     ← AI writes ideas here
├── approved/       ← Human moves items here when ready
├── parked/         ← Deferred (but not forgotten)
└── implemented/    ← Done and verified
```

**The workflow:**

1. **AI scouts** — identifies opportunities, writes structured backlog items to `candidates/`
2. **Human curates** — reviews, approves, parks, or rejects candidates
3. **Builder implements** — works from approved items, moves to `implemented/` when done

Each backlog item includes priority, effort estimate, risks, a minimal implementation plan, and a clear definition of done. The AI *never* moves items out of `candidates/` — that's the human's job. This separation of authority prevents scope creep and hallucinated priorities.

---

## External AI Review

The `sprint-review.md` file enables a powerful quality pattern: **hand your sprint results to a fresh AI for review.**

The reviewing AI wasn't involved in building the code, so it:
- Questions assumptions the builder AI took for granted
- Spots patterns the builder was too close to see
- Evaluates quality without sunk-cost attachment

**How to use it:**

1. At the end of a sprint, open a new conversation with any AI
2. Share the sprint results, relevant code, and `sprint-review.md`
3. Ask it to review and document findings
4. Action, park, or decline the findings

---

## Getting Started

### If you have `init-agent` installed:

```bash
init-agent my-project --profile python
```

This creates the full AgentFlow document set, ready to go.

### Updating existing projects:

When templates improve (new Development Loop, better guardrails, etc.), push those changes to existing projects:

```bash
cd my-existing-project
init-agent --update --profile python
```

This updates **all template files** for the specified profile. Files that haven't changed are skipped automatically. It detects your project name from `context.md` and applies variable substitution.

### If you're setting up manually:

Create these files in your project root:

1. `AGENTS.md` — rules, guardrails, Development Loop, document protocol
2. `context.md` — current state snapshot and next actions
3. `WHERE_AM_I.md` — product-level progress tracking
4. `sprint-plan.md` — current sprint tasks
5. `result-review.md` — running work log
6. `product-definition.md` — what you're building and why
7. `project-plan.md` — strategic roadmap

### Your First Prompt

Open a conversation with any AI and say:

> "Read AGENTS.md and context.md. You are continuing work on [project name]. Pick up from the Next Actions Queue in context.md."

That's it. AgentFlow is running.

---

## The AgentFlow Principles

1. **Documentation is the interface** — The markdown files aren't bureaucracy. They're the API between you and your AI collaborators.

2. **Context preservation beats conversation history** — Chat logs are ephemeral. `context.md` is durable.

3. **Human authority, AI autonomy** — The AI works independently within guardrails *you* define. It doesn't surprise you.

4. **Test As Lee** — The AI does the QA so the human can focus on product decisions.

5. **Small increments** — Build the smallest thing that works, validate it, then expand.

6. **Artifacts over chat** — Meaningful output goes in files, not buried in conversation. Files persist; conversations don't.

---

*Generated from [init-agent](https://github.com/leebase/init-agent) — the tool that bootstraps AgentFlow projects.*
