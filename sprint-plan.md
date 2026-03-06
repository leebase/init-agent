# init-agent Sprint Plan

---

## Sprint Status Dashboard

| Attribute | Value |
|-----------|-------|
| **Current Sprint** | Sprint 8 — Safe Existing-Project Refresh |
| **Version Target** | v1.2.0 |
| **Last Updated** | 2026-03-06 |

---

## Sprint 8 — Safe Existing-Project Refresh ✅ COMPLETE

> v1.2.0 — Preserve project state when re-running init-agent

### Goals

When `init-agent` runs against an existing project, it should refresh only the agent contract layer (`AGENTS.md` and `skills/*`) and preserve living project-memory documents such as `context.md` and `WHERE_AM_I.md`.

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Define refreshable vs preserved files | ✅ | Contract files refreshable; project-memory docs preserved |
| Change scaffold-on-existing-dir behavior | ✅ | Existing managed projects now refresh only `AGENTS.md` and `skills/*` |
| Change `--update` behavior | ✅ | `--update` rewrites contract files only |
| Update overwrite/force semantics | ✅ | `--force` no longer deletes the target directory |
| Add regression coverage | ✅ | Integration tests cover rerun preservation, missing-doc backfill, and `--update --dir` project-name handling |
| Update README and generated docs | ✅ | Repo README plus profile templates now document contract-only refresh |

**Acceptance Criteria**
- Re-running `init-agent` in an existing project never overwrites `context.md`, `WHERE_AM_I.md`, `result-review.md`, or similar stateful docs.
- `AGENTS.md` and `skills/*` are refreshed on rerun, with overwrite prompts unless `--force` is used.
- `--update` touches only `AGENTS.md` and `skills/*`.
- Automated tests cover the preservation rules.

---

## Sprint 1 — Foundation ✅ COMPLETE

> v0.1.0 — Core CLI with basic language support

| Task | Status |
|------|--------|
| CLI argument parsing | ✅ |
| Language enum and detection | ✅ |
| Help text and version | ✅ |
| Error handling | ✅ |
| AGENTS.md template | ✅ |
| context.md template | ✅ |
| sprint-plan.md template | ✅ |
| result-review.md template | ✅ |
| backlog/schema.md template | ✅ |
| .gitignore template | ✅ |
| Create directory structure | ✅ |
| Write template files | ✅ |
| Create backlog folders | ✅ |
| Create logs folders | ✅ |
| Initialize git | ✅ |
| Create build.zig | ✅ |
| Compile successfully | ✅ |
| Test with example project | ✅ |
| GitHub Actions CI workflow | ✅ |
| GitHub Actions release workflow | ✅ |
| Cross-platform build targets | ✅ |
| Makefile with release targets | ✅ |
| Release script | ✅ |
| Installation docs | ✅ |

**Deliverable:** Working CLI that scaffolds projects with `init-agent <name> --lang <lang>`

---

## Sprint 2 — Profile System 🔄 IN PROGRESS

> v0.2.0 — Refactor to profile-based architecture

### Goals

Refactor from `--lang` flag to `--profile` system with layered templates.

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Design profile registry | ⬜ | Map profile name → list of template assets |
| Create `templates/common/` | ⬜ | agent.md, WHERE_AM_I.md, lees-process.md |
| Create `templates/python/` | ⬜ | README.md, pyproject.toml, src/__init__.py |
| Create `templates/web-app/` | ⬜ | README.md, package.json, src/ |
| Create `templates/zig-cli/` | ⬜ | README.md, build.zig, src/main.zig |
| Refactor CLI: `--profile` flag | ⬜ | Replace `--lang` with `--profile` |
| Add `--list` command | ⬜ | List available profiles |
| Add `--force` flag | ⬜ | Overwrite existing files |
| Update template variable syntax | ⬜ | Change `{VAR}` to `{{VAR}}` |
| Update documentation | ⬜ | README, AGENTS.md for new CLI |

**Deliverable:** `init-agent --profile python my-project` works with layered templates

---

## Sprint 3 — Placeholder Substitution

> v0.3.0 — Smart template variables

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Add `--name` flag | ✅ | Override project display name |
| Add `--author` flag | ✅ | Already existed |
| Implement substitution engine | ✅ | Already existed |
| Add substitution tests | ✅ | 17 test cases for replaceAll, substituteVariables, hasUnresolvedPlaceholders |
| Template validation | ✅ | Warns on unresolved {{VAR}} patterns |

**Deliverable:** ✅ Templates render with actual project names, dates, and author info. Unit tests pass.

---

## Sprint 4 — Enhanced CLI & Dry Run

> v0.4.0 — Professional CLI experience

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Add `--dry-run` flag | ✅ | Print what would be written |
| Add `--dir` flag | ✅ | Already existed |
| Interactive mode (`--interactive`) | ✅ | Prompt for missing values |
| Colored output | ✅ | ANSI colors, NO_COLOR support |
| Verbose mode (`--verbose`) | ✅ | Detailed logging |
| File overwrite rules | ✅ | Smart merge vs replace with prompts |

**Deliverable:** ✅ Production-ready CLI with all quality-of-life features

---

## Sprint 5 — Release Pipeline Polish

> v1.0.0 — Stable release

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Version stamping | ✅ | Embed version from git tags at build time |
| Automated changelog | ✅ | Generate from git commits via scripts/changelog.sh |
| Code signing (macOS) | ⏭️ | Deferred to post-v1.0 (requires Apple Dev account) |
| Homebrew formula | ✅ | homebrew/init-agent.rb created |
| Installation script | ✅ | scripts/install.sh - curl \| sh one-liner |
| Comprehensive tests | ✅ | 18 integration tests in tests/integration.sh |

**Deliverable:** v1.0.0 release with professional distribution

---

## Sprint 6 — Update Intelligence & Agent Completeness ✅ COMPLETE

> v1.1.0 — Smart updates and better agent contracts

### Tasks

| Task | Status | Notes |
|------|--------|-------|
| Auto-detect profile for `--update` (BI-001) | ✅ | Fallback inferencing from `pyproject.toml`, `package.json`, etc. |
| Explicit Done Checklist in AGENTS.md (BI-002) | ✅ | Add checkable mode/verification checklist to template |

**Deliverable:** Smoother `--update` UX and more robust agent contracts

---

## Profile Registry (Planned)

> **Note:** These are templates for generated projects, NOT project files.
> Our own `AGENTS.md` and `context.md` remain in the project root.

```
templates/
  common/           # Always included in generated projects
    agent.md        # Lowercase - for generated projects
    WHERE_AM_I.md
    lees-process.md
    sprint-plan.md
    sprint-review.md
    product-definition.md
    architecture.md
    .gitignore

  python/           # --profile python
    README.md
    pyproject.toml
    src/__init__.py

  web-app/          # --profile web-app
    README.md
    package.json
    src/

  zig-cli/          # --profile zig
    README.md
    build.zig
    src/main.zig
```

---

## Template Variables

| Variable | Source | Example |
|----------|--------|---------|
| `{{PROJECT_NAME}}` | CLI arg or `--name` | `my-awesome-project` |
| `{{DATE}}` | Current date | `2026-02-17` |
| `{{AUTHOR}}` | `--author` flag or git config | `Lee Harrington` |
| `{{PROFILE}}` | Selected profile | `python` |

---

## CLI Evolution

### v0.1.0 (Current)
```bash
init-agent my-project --lang python
```

### v0.2.0 (Target)
```bash
init-agent my-project --profile python
init-agent --list                    # List profiles
init-agent my-project --force        # Overwrite existing
```

### v0.3.0 (Target)
```bash
init-agent my-project --profile python --author "Lee" --name "custom-name"
```

### v0.4.0 (Target)
```bash
init-agent my-project --profile python --dry-run
init-agent my-project --profile python --dir ./output
```

---

## Definition of Done (per Sprint)

- [ ] All tasks in sprint completed
- [ ] Code compiles without warnings
- [ ] Tests pass (`zig build test`)
- [ ] Example project created and verified
- [ ] Documentation updated
- [ ] result-review.md updated

---

*End of Sprint Plan*
