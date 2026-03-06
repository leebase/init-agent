# init-agent

A Zig CLI for scaffolding AI-agent projects around the AgentFlow methodology.

`init-agent` creates an opinionated project kit that gives you shared memory, operating rules, sprint structure, backlog flow, and profile-specific starter files so a human and an AI agent can keep working across sessions without losing the plot.

## What It Generates

Every scaffold includes the AgentFlow document system:

- `AGENTS.md` as the contract for any AI working in the repo
- `context.md` as the session handoff note
- `WHERE_AM_I.md` as the product-level orientation doc
- `result-review.md` as the running completion log
- `sprint-plan.md`, `sprint-review.md`, `project-plan.md`, and backlog structure
- `skills/` for task-specific workflows such as development, testing, documentation, backlog work, and code review

On top of that, `init-agent` adds a profile-specific starter project:

- `python`: Python package with `pyproject.toml` and `src/` layout
- `web-app`: React + TypeScript + Vite app
- `zig-cli`: Zig command-line tool

## The Methodology

The scaffolds are built around **AgentFlow**, your documentation-driven workflow for human-AI collaboration.

If someone wants the full explanation of the methodology itself, point them to:

- [how-to-work-with-agentic-ai.md](./how-to-work-with-agentic-ai.md)

That doc explains the document system, session lifecycle, autonomy modes, development loop, and why the project uses markdown files as shared memory between humans and AI agents.

## Installation

`init-agent` is written in Zig `0.13.0`.

```bash
git clone https://github.com/lee/init-agent.git
cd init-agent
make install
```

For a user-local install:

```bash
make install-local
```

## Usage

Create a new project:

```bash
init-agent my-awesome-app --profile web-app --author "Lee"
```

List available profiles:

```bash
init-agent --list
```

Create a project without initializing git:

```bash
init-agent my-lib --profile python --no-git
```

## Updating Existing Projects

You can refresh an existing init-agent project without overwriting its living project memory:

```bash
cd my-awesome-app
init-agent --update --profile web-app
```

Current update behavior:

- `AGENTS.md` and `skills/*` are treated as refreshable contract files
- `context.md`, `WHERE_AM_I.md`, `result-review.md`, and other project-owned files are preserved
- re-running `init-agent` inside an existing managed project follows the same rule
- `--force` skips prompts for refreshable files, but does not delete the target directory

This keeps the methodology upgradeable without wiping the state the methodology is supposed to preserve.

## Why This Project Exists

The problem `init-agent` is solving is simple: AI agents are stateless, but projects are not.

Without a stable document system:

- every new session starts from zero
- each model invents its own workflow
- important decisions disappear into chat history
- handoffs between models or people become unreliable

`init-agent` standardizes that starting point so every project begins with a usable collaboration contract instead of ad hoc prompts.

## Development

```bash
make build
make test
make check-sync
```

### Dual-Template Rule

This project embeds templates at compile time with `@embedFile`.

- human-editable source templates live in `templates/`
- compiled templates live in `src/templates/`

If you change a template, update both trees. `make check-sync` verifies they still match.
