# init-agent

A Zig tool for scaffolding AI-agent projects using the **AgentFlow** methodology.

`init-agent` generates project kits that establish shared memory (state) between you and any AI working on your codebase. It provides the structured files, conventions, and skills necessary to keep AI agents oriented, deterministic, and autonomous without drift.

## What's New: Skills & Mandatory Code Review

The latest `init-agent` introduces two major upgrades to the AgentFlow methodology:

### 1. The Skills Architecture

Previously, `AGENTS.md` was bloated with every possible process and workflow instruction, causing context exhaustion and confusion.

Now, `AGENTS.md` is a slim router. The actual workflows live in `skills/` files, grouped logically:
- `development-loop.md` — how to write, test, and commit code
- `test-as-lee.md` — how to verify work before presenting it
- `documentation.md` — what to update and when
- `backlog.md` — how to scope and create tasks
- `code-review.md` — how to perform an objective codebase review

Agents only load the specific skill they need based on triggers defined in `AGENTS.md`. This drops the cognitive load significantly and makes agents far more effective at complex tasks.

### 2. Mandatory Code Review

Code review is no longer a manual afterthought — it's wired into the sprint lifecycle:
- The sprint `Definition of Done` explicitly demands running the `skills/code-review.md` protocol.
- The review outputs structurally to `code-reviews/review-YYYY-MM-DD.md` (a directory now scaffolded by all profiles).
- The `sprint-review.md` template prompts an external/fresh AI to pull that review file when assessing the sprint's quality.

You cannot close a sprint in an AgentFlow project without an AI pointing out the edge cases you missed.

## Installation

```bash
# macOS / Linux (from source)
git clone https://github.com/lee/init-agent.git
cd init-agent
make install
```

## Usage

Create a new project:
```bash
init-agent my-awesome-app --profile web-app --author "Lee"
```

Available profiles:
- `python`: Python package with `pyproject.toml`
- `web-app`: React + Vite + TypeScript application
- `zig-cli`: Zig command-line tool

Update an existing project's AgentFlow files without overwriting user data:
```bash
cd my-awesome-app
init-agent --update --profile web-app
```

## Development

`init-agent` is written in Zig 0.13.0.

```bash
# Build
make build

# Test
make test

# Verify template sync (always run before committing)
make check-sync
```

### The Dual-Template Rule
This project embeds templates at compile time using `@embedFile`.
- Human-editable templates live in `templates/` (project root).
- Compiled templates live in `src/templates/`.
**When you edit a template, you must update both.** Use `make check-sync` to verify.
