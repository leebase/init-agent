# Skill: Delegate Implementation To A Worker Harness

> Load this skill when a planning-capable session is about to implement a
> well-specified slice and a cheaper or separate worker harness should do the
> typing.

---

## The Split

- **Planner**: rehydrate, decide, write contracts or plans, write task specs,
  review every diff, run final verification, update durable docs, and commit
  when allowed.
- **Worker**: implement exactly one spec with a narrow diff, focused tests, and
  an honest report back.

Spec quality substitutes for worker context. If the worker needs the chat
history to understand the task, the task is not ready to delegate.

---

## Task Spec Format

Every spec must stand alone. Include objective, files to touch, behavior
details, tests, verification commands, and explicit boundaries.

Do not delegate contract decisions, review judgment, session-memory updates,
commits, pushes, or work that changes halt/approval/evidence semantics without
a written contract.

---

## After The Worker Returns

The worker's report is untrusted prose. Read the full diff, re-run the focused
tests, check for boundary violations, and run a real-boundary smoke whenever
the work touches a subprocess seam.
