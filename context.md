# init-agent - Context

> **Purpose**: Working memory for session continuity.

---

## Snapshot

| Attribute | Value |
|-----------|-------|
| **Phase** | Sprint 2 — Profile System |
| **Mode** | 3 (Full autonomy for this project) |
| **Last Updated** | 2026-02-17T15:00:00Z |

---

## What's Happening Now

### Current Focus
Sprint 2 complete! Profile system implemented and tested. Ready for Sprint 3 (placeholder enhancements).

### Recently Completed (Sprint 2)
- ✅ Created templates/common/ with 7 core agent kit files
- ✅ Created templates/python/ profile (pyproject.toml, src layout)
- ✅ Created templates/web-app/ profile (React + Vite + TypeScript)
- ✅ Created templates/zig-cli/ profile (build.zig, main.zig)
- ✅ Refactored CLI with profile registry system
- ✅ Added `--profile`, `--list`, `--force`, `--author` flags
- ✅ Implemented variable substitution ({{PROJECT_NAME}}, {{DATE}}, {{AUTHOR}})
- ✅ All profiles tested and working
- ✅ Updated README documentation

### Next Steps (Sprint 3 - Placeholder Substitution)
1. Add `--name` flag for custom project names
2. Add `--date` flag for custom dates
3. Add more template variables ({{VERSION}}, {{DESCRIPTION}})
4. Template validation (ensure all placeholders resolved)
5. Add substitution unit tests

### Next Steps (Future Sprints)
- Sprint 3: Placeholder substitution (`--name`, `--author`)
- Sprint 4: Enhanced CLI (`--dry-run`, `--dir`, colored output)
- Sprint 5: v1.0.0 release (Homebrew, install script)

---

## Decisions Locked

| Decision | Rationale | Date |
|----------|-----------|------|
| Language: Zig | Fast, portable, single binary, no runtime deps | 2026-02-17 |
| Templates embedded in source | Self-contained binary, no file reading at runtime | 2026-02-17 |
| Multi-language support | Different users prefer different languages | 2026-02-17 |
| TinyClaw methodology | Proven in LeeClaw, reduces risk | 2026-02-17 |
| Profile-based architecture | Cleaner than `--lang` flag, allows stacking | 2026-02-17 |
| Template variable substitution | {{PROJECT_NAME}}, {{DATE}}, {{AUTHOR}} support | 2026-02-17 |

---

## Active Issues

None yet.

---

*This file is updated every session.*
