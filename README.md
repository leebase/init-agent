# init-agent

A Zig CLI tool that bootstraps AI-agent projects with battle-tested patterns from the LeeClaw collaboration.

## Quick Start

```bash
# Install init-agent (after building)
cp zig-out/bin/init-agent ~/.local/bin/

# Create a new AI-agent project
init-agent my-project --lang python

# Or with options
init-agent my-api --lang python --template full --path ./projects
```

## What You Get

```
my-project/
├── AGENTS.md              # AI agent guide (contract between human & AI)
├── context.md             # Working memory / session baton
├── result-review.md       # Running log of completed work
├── product-definition.md  # Vision and constraints
├── sprint-plan.md         # Current sprint tracking
├── backlog/               # Backlog workflow
│   ├── schema.md
│   ├── candidates/        # AI generates here
│   ├── approved/          # Human approves here
│   ├── parked/            # Deferred items
│   └── implemented/       # Completed items
├── src/                   # Source code
├── tests/                 # Tests
└── logs/                  # Session logs
```

## Installation

### Prerequisites

- [Zig](https://ziglang.org/download/) 0.13.0 or later

### Build from Source

```bash
git clone https://github.com/yourusername/init-agent.git
cd init-agent
zig build -Doptimize=ReleaseFast

# Install
cp zig-out/bin/init-agent ~/.local/bin/
# or
cp zig-out/bin/init-agent /usr/local/bin/
```

## Usage

```bash
init-agent <project-name> [options]

Options:
  --lang <lang>       Language: python, zig, ts, rust, go (default: python)
  --template <type>   Template: minimal, full (default: full)
  --path <path>       Target directory (default: ./<name>)
  --no-git            Skip git initialization
  
  -h, --help          Show help
  -v, --version       Show version

Examples:
  # Python API project
  init-agent my-api --lang python

  # Zig CLI tool
  init-agent my-cli --lang zig --template minimal

  # TypeScript web app
  init-agent my-app --lang ts
```

## Philosophy

init-agent encodes the lessons learned from LeeClaw into a reusable tool:

1. **Documentation as Contract** - AGENTS.md establishes clear permissions/constraints
2. **Context Preservation** - context.md maintains state across sessions
3. **Result Logging** - result-review.md tracks progress
4. **TinyClaw Methodology** - Small, working, validated increments
5. **Backlog Workflow** - Structured path from ideas to implementation

## Language Support

| Language | Status | Template |
|----------|--------|----------|
| Python   | ✅ Ready | Full, Minimal |
| Zig      | ✅ Ready | Full, Minimal |
| TypeScript | 🚧 Planned | - |
| Rust     | 🚧 Planned | - |
| Go       | 🚧 Planned | - |

## Development

```bash
# Run tests
zig build test

# Run with example args
zig build run -- my-test-project --lang python

# Debug build
zig build

# Release build
zig build -Doptimize=ReleaseFast
```

## Project Structure

```
init-agent/
├── build.zig          # Zig build configuration
├── src/
│   └── main.zig       # CLI implementation
├── templates/         # Template files
│   ├── base/          # Language-agnostic templates
│   ├── python/        # Python-specific
│   └── zig/           # Zig-specific
├── AGENTS.md          # This project's agent guide
├── context.md         # This project's working state
└── product-definition.md
```

## License

MIT

## Acknowledgments

Built from patterns learned in [LeeClaw](https://github.com/yourusername/leeclaw).
