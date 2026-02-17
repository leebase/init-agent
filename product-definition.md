# init-agent Product Definition

## Vision

A Zig-based CLI tool that bootstraps AI-agent projects with battle-tested patterns from the LeeClaw collaboration. One command creates a complete project scaffold with documentation, conventions, and tooling that "just works" for human-AI pair programming.

## Problem Statement

Starting a new AI-agent project is painful:
- **No standard structure** - Every project reinvents conventions
- **Context loss** - AI agents don't know project history without explicit documentation
- **Scattered knowledge** - Lessons learned in one project don't transfer
- **Setup friction** - Hours spent on boilerplate before real work begins

## Solution

`init-agent` creates a complete, opinionated project scaffold in seconds:

```bash
# Create new AI-agent project
init-agent my-project --lang python

# What you get:
my-project/
├── AGENTS.md           # AI agent guide (project-specific)
├── context.md          # Working memory / session baton
├── result-review.md    # Running log of completed work
├── product-definition.md
├── sprint-plan.md
├── backlog/
│   ├── schema.md
│   ├── candidates/
│   ├── approved/
│   ├── parked/
│   └── implemented/
├── logs/
│   ├── sessions/
│   └── summaries/
├── src/                # Language-specific scaffold
└── tests/
```

## Target Users

1. **Solo developers** using AI assistants (Claude, ChatGPT, Kimi)
2. **Teams** with mixed human-AI contributions
3. **AI-native agencies** doing client work
4. **Open source maintainers** accepting AI-generated PRs

## Core Philosophy

### 1. Documentation as Contract

The scaffold establishes a **contract** between human and AI:
- Human writes product vision → AI implements within constraints
- AI updates context.md → Human knows current state
- AI logs results → Human reviews progress

### 2. TinyClaw Methodology

Every scaffolded project follows TinyClaw principles:
- **Small**: Minimal viable first, expand after validation
- **Working**: Everything functional at each commit
- **Validated**: Tests pass before moving on
- **Then expand**: Build on proven foundations

### 3. Agent-First Design

Documentation is written **for agents**, not humans:
- Precise, unambiguous language
- Code examples over explanations
- Checklists over essays
- Exit codes, CLI flags, file paths specified

## Key Features

### 1. Multi-Language Support

```bash
init-agent my-api --lang python    # FastAPI scaffold
init-agent my-cli --lang zig       # CLI tool scaffold
init-agent my-web --lang ts        # Next.js scaffold
init-agent my-lib --lang rust      # Library scaffold
```

Each language gets:
- Appropriate project structure
- Dependency management setup
- Testing framework config
- CI/CD templates (optional)

### 2. Template System

Templates are **composable**:

```bash
# Base scaffold + specific modules
init-agent my-project --lang python --template full

# Minimal scaffold
init-agent my-project --lang python --template minimal

# Add specific modules
init-agent my-project --lang python --add budget --add backlog
```

Available modules:
- `budget` - Token budget governance
- `backlog` - Backlog management
- `scheduler` - Task scheduling
- `github` - GitHub integration
- `docker` - Container setup
- `tests` - Testing framework

### 3. Context Preservation

Every project gets context-aware documentation:

**context.md**: Session baton file
```markdown
## Snapshot
| Attribute | Value |
|-----------|-------|
| **Phase** | Bootstrap |
| **Mode** | 1 (Research) |
| **Last Updated** | 2026-02-17T12:00:00Z |

## What's Happening Now
[AI fills this in each session]

## Decisions Locked
[Key decisions with rationale]
```

**AGENTS.md**: Project guide for AI
```markdown
# Agent Guide

## Your Role
[What AI should do in this project]

## Guardrails
- ✅ Allowed: [explicit permissions]
- ❌ Not allowed: [explicit prohibitions]

## Patterns
[Reusable code patterns]

## File Locations
[Where things live]
```

### 4. Sprint-Aware Structure

Built-in sprint planning:

```
sprint-plan.md          # Current sprint
templates/
  sprint-plan.md        # Sprint template
result-review.md        # Running log
```

### 5. Backlog System

Complete backlog workflow:

```
backlog/
├── schema.md           # Item schema definition
├── candidates/         # AI writes here
├── approved/          # Human moves here
├── parked/            # Deferred items
└── implemented/       # Completed items
```

## Non-Goals

1. **Not a code generator** - Scaffolds structure, not implementation
2. **Not a framework** - Projects remain independent
3. **Not CI/CD** - Templates provided, but not the system
4. **Not deployment** - Focus on development workflow

## Constraints

1. **Zig implementation** - Fast, portable, single binary
2. **No runtime dependencies** - Self-contained tool
3. **Offline capable** - Works without network
4. **Git-native** - Integrates with git workflow

## Success Metrics

- [ ] New project scaffolded in < 5 seconds
- [ ] Agent can start working immediately (no clarification needed)
- [ ] Context preserved across sessions
- [ ] Documentation maintained automatically
- [ ] Human can onboard to project in < 2 minutes

## Architecture

```
init-agent/
├── src/
│   ├── main.zig         # CLI entry point
│   ├── templates.zig    # Template loading/rendering
│   ├── config.zig       # Project configuration
│   └── scaffold.zig     # File generation logic
├── templates/           # Built-in templates
│   ├── base/           # Language-agnostic
│   ├── python/         # Python-specific
│   ├── zig/            # Zig-specific
│   └── ...
└── init-agent          # Compiled binary
```

## CLI Interface

```bash
# Create new project
init-agent <project-name> [options]

Options:
  --lang <lang>         Language: python, zig, ts, rust, go
  --template <type>     Template: minimal, full, api, cli, lib
  --path <path>         Target directory (default: ./<name>)
  --no-git              Skip git initialization
  
  --add <module>        Add specific module (repeatable)
  --skip <module>       Skip default module (repeatable)
  
  -h, --help            Show help
  -v, --version         Show version

# Update existing project
init-agent --update     # Add missing scaffold files

# List templates
init-agent --list-templates
init-agent --list-modules

# Validate project
init-agent --check      # Verify scaffold completeness
```

## Default Scaffold (Full Template)

```
my-project/
├── AGENTS.md
├── context.md
├── result-review.md
├── product-definition.md
├── sprint-plan.md
├── README.md
├── .gitignore
│
├── backlog/
│   ├── schema.md
│   ├── candidates/
│   ├── approved/
│   ├── parked/
│   └── implemented/
│
├── logs/
│   ├── sessions/
│   └── summaries/
│
├── src/                    # Language-specific
│   └── [scaffolded code]
│
├── tests/                  # Language-specific
│   └── [test scaffold]
│
└── docs/                   # Additional documentation
    └── conventions.md
```

## Example Session

```bash
# Human creates project
$ init-agent leeclaw --lang python --template full

✅ Created leeclaw/
✅ Initialized git repository
✅ Generated documentation scaffold
✅ Created backlog structure
✅ Set up Python project structure

Next steps:
1. Edit product-definition.md with your vision
2. Run: cd leeclaw && git add -A && git commit -m "Initial commit"
3. Start working with your AI agent!

# AI reads AGENTS.md and context.md
# AI understands the project immediately
# AI starts implementing based on product-definition.md
```

## Lessons Learned (from LeeClaw)

### What Worked

1. **AGENTS.md as contract** - Clear permissions and constraints
2. **context.md as baton** - Session continuity across interruptions
3. **result-review.md as log** - Trackable progress, searchable history
4. **Backlog folders as state machine** - Clear workflow (candidates → approved → implemented)
5. **TinyClaw discipline** - Small, working, validated increments

### What We'll Improve

1. **Auto-update context.md** - Tool should timestamp and track changes
2. **Schema validation** - Validate backlog items against schema
3. **Template versioning** - Update scaffolds without breaking existing projects
4. **Plugin system** - Allow custom templates and modules

## Future Roadmap

### v0.1.0 - MVP
- [ ] Zig CLI with basic scaffold
- [ ] Python and Zig language support
- [ ] Full and minimal templates
- [ ] Built-in modules: backlog, context

### v0.2.0 - Extended Languages
- [ ] TypeScript/JavaScript support
- [ ] Rust support
- [ ] Go support

### v0.3.0 - Smart Features
- [ ] Auto-detect existing projects
- [ ] Update existing scaffolds
- [ ] Validate scaffold completeness
- [ ] Plugin system for custom templates

### v1.0.0 - Stable
- [ ] All major languages supported
- [ ] Comprehensive module library
- [ ] Documentation generation
- [ ] IDE integrations

## References

- LeeClaw project: `/Users/leeharrington/projects/leeclaw`
- TinyClaw methodology: See LeeClaw AGENTS.md
- Sprint planning: See LeeClaw sprint-plan-*.md files
