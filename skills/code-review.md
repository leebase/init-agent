# Skill: Code Review

> Load this skill before closing a sprint or tagging a release for init-agent.

---

## Review-Only Rules

**Do not modify files. Do not commit. Do not apply patches.**

Output goes to `code-reviews/review-YYYY-MM-DD.md`. If you find an obvious fix, describe it precisely — file, line, before/after — but do not apply it unless explicitly asked.

---

## Phase 0: Orient First

Read before reviewing anything:
1. `architecture.md` — design decisions and known tradeoffs
2. `product-definition.md` — what this is supposed to do
3. `sprint-plan.md` — what changed this sprint (scope the review)

**init-agent's architecture in brief:**
- Single Zig binary, no runtime dependencies
- Templates embedded via `@embedFile` at compile time from `src/templates/`
- `templates/` (root) is the human-editable copy — must match `src/templates/`
- Profile system: each profile = list of `TemplateFile` entries + directories list
- `--update` iterates the same file list and overwrites contract files
- Template variable substitution via `substituteVariables()` with `{{VAR}}` syntax

---

## Phase 1: Run the Checks

```bash
# Must pass before the review means anything
/home/lee/zig/zig build -Doptimize=ReleaseFast
/home/lee/zig/zig build test

# Smoke test all 3 profiles
./zig-out/bin/init-agent review-test --profile python --force && \
./zig-out/bin/init-agent review-test2 --profile web-app --force && \
./zig-out/bin/init-agent review-test3 --profile zig-cli --force
ls review-test/skills/ review-test2/skills/ review-test3/skills/
rm -rf review-test review-test2 review-test3
```

If any check fails — **that is Finding #1.** Do not continue as if the project is healthy.

---

## Phase 2: Review Lenses

### A. Correctness & Error Handling (highest priority for Zig code)

- Does every function that can fail handle errors explicitly? Are any errors swallowed with `_ = result`?
- `while (true)` loops: is there a guaranteed exit condition under all inputs, including closed/piped stdin?
- Resource cleanup: are files closed, memory freed on every error path (including early returns)?
- Template sync: does `src/templates/` match `templates/`? A mismatch compiles but produces stale output.
- `substituteVariables()`: are there template variables in the skills files that will appear unresolved in generated output?

### B. Security

init-agent's threat surface is limited (local CLI, no network) but not zero:
- Are any user-provided strings (project name, author, output dir) used in subprocess args without sanitization? (`git init <output_dir>`)
- Path traversal: can a crafted `--dir` argument write files outside the intended directory?
- Can `--profile` be crafted to escape the profile registry lookup?

### C. Edge Cases

- Empty `--name` or `--author` flags — does the tool behave sensibly or crash?
- Project name that is a reserved OS path (e.g., `con` on Windows, `.` or `..`)
- `--force` on an existing non-directory path (file with the same name as the target dir)
- `--update` run from a directory that has no `context.md` and no profile signature files

### D. Code Quality

- Are there any functions in `main.zig` doing more than one distinct job? (It's a large file — scope creep is a real risk here)
- Is the dual template tree sync requirement documented anywhere agents will find it? (It's easy to forget)
- Are there Zig 0.13.0 API calls that will break when upgrading Zig?

### E. Tests

- What does the current test suite cover? (replaceAll, substituteVariables, hasUnresolvedPlaceholders — string logic)
- What's NOT covered: profile registry, scaffold creation, --update behavior, git init, interactive mode, stdin EOF handling
- What's the highest-value missing test?

### F. Documentation

- Does `README.md` accurately reflect the current CLI flags and profile list?
- Are sprint-plan.md statuses current?
- Are the skill files themselves clear and actionable — or are any of them drifting toward generic filler?

---

## Phase 3: Write the Review File

Output to `code-reviews/review-YYYY-MM-DD.md`:

```markdown
# Code Review — YYYY-MM-DD

## Checks Run
| Command | Result |
|---------|--------|
| zig build | ✅ / ❌ |
| zig build test | ✅ / ❌ |
| Smoke test (3 profiles) | ✅ / ❌ |

## Findings

| ID | Severity | Category | Location | Problem | Proposed Fix |
|----|----------|----------|----------|---------|--------------|
| R001 | High | Correctness | `src/main.zig:247 writeFile()` | ... | ... |

## Remediation Roadmap

### Fix Now
### Fix Soon
### Fix Later

## Patch Suggestions (text only — do not apply)
```

---

## Severity Guide

| Level | Meaning |
|-------|---------|
| **Critical** | Crash in normal use, data loss, security breach |
| **High** | Wrong behavior real users will hit |
| **Med** | Wrong behavior in edge cases, poor degradation |
| **Low** | Quality/maintainability, no immediate risk |

Do not inflate severity. A Low reported as Critical trains Lee to ignore everything.

---

## Good vs. Bad Finding

**Good:** "In `src/main.zig:595`, `promptFileAction()` has `while (true)` with `if (bytes_read == 0) continue` — when stdin is piped or closed, this spins forever at 100% CPU. Fix: return `.skip` on EOF."

**Bad:** "Error handling could be improved throughout the codebase."

The first is actionable. The second is noise.

*Last updated: 2026-03-05*
