# Skill: Use Agent-Orch And Auto-Orch

> Load this skill when you need to run a task through governed execution,
> convert a sprint plan into a playbook, launch or monitor a governed workflow,
> or decide between Agent-Orch and Auto-Orch.

---

## Choose The System

Use **Agent-Orch** for one bounded delivery slice: a feature, fix, sprint item,
PR-shaped task, or acceptance-criteria-driven workflow.

Use **Auto-Orch** for an ongoing mission: backlog-driven cycles, cron-fired
operation, mission memory, learnings, and repeated autonomous selection.

Auto-Orch's Execute stage launches Agent-Orch through the real CLI boundary.
Do not replace that seam with ad hoc scripts or mock-only proof.

---

## Working Rules

- Read the target project's `AGENTS.md`, `context.md`, `WHERE_AM_I.md`, and
  `sprint-plan.md` before authoring a workflow.
- Start from a known template when one exists.
- Map acceptance criteria into structural validation rules, not prose wishes.
- Keep smoke and review gates on code-producing work.
- Lint or preflight before launch.
- Stop for human approval when the workflow can spend money, deploy, modify
  important files, or run unattended.
- Relay trusted launch facts exactly from CLI output or launch reports.
- Inspect artifacts and evidence before retrying failed runs.

---

## Anti-Patterns

| Do not | Do instead |
|--------|------------|
| Write playbooks from scratch when templates exist | Start from a known template and specialize |
| Use `file_exists` as the only gate | Validate content, schema, command output, or hashes |
| Launch without lint/preflight | Fix findings first, then launch |
| Treat worker narration as proof | Trust validators, artifacts, exit codes, and evidence |
| Mock the subprocess seam as the only proof | Run the real command boundary with fixtures |
