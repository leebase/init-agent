# init-agent

A Zig CLI tool that bootstraps AI-agent projects with battle-tested patterns from the LeeClaw collaboration.

## Quick Start

```bash
# Install init-agent (macOS/Linux)
curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh

# Create a new AI-agent project
init-agent my-project --profile python

# List available profiles
init-agent --list

# Or with options
init-agent my-api --profile web-app --author "Jane Doe" --force
```

## Profiles

| Profile | Description | Files Generated |
|---------|-------------|-----------------|
| `python` | Python package with pyproject.toml, src layout, and tooling | AGENTS.md, README.md, pyproject.toml, src/ |
| `web-app` | Modern web app with React, TypeScript, and Vite | AGENTS.md, README.md, package.json, src/, vite.config.ts |
| `zig-cli` | Command-line tool built with Zig | AGENTS.md, README.md, build.zig, src/main.zig |

## What You Get

Every project includes the **core agent kit**:

```
my-project/
├── AGENTS.md              # AI agent guide (contract between human & AI)
├── WHERE_AM_I.md          # Quick orientation for agents
├── lees-process.md        # Lee's working process
├── product-definition.md  # Vision and constraints
├── sprint-plan.md         # Current sprint tracking
├── sprint-review.md       # Sprint retrospective
├── architecture.md        # Architecture decisions
└── .gitignore             # Git ignore patterns
```

Plus profile-specific files (README, build configs, source code, etc.)

## Installation

### Option 1: curl | sh (Recommended)

Install the latest release with one command:

```bash
curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh
```

Install a specific version:

```bash
curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh -s -- v1.0.0
```

The script will:
- Detect your OS and architecture
- Download the appropriate binary from GitHub releases
- Install to `/usr/local/bin` (with sudo) or `~/.local/bin`
- Verify the installation

**Supported platforms:** macOS (Apple Silicon, Intel), Linux (x86_64, ARM64)

**Windows users:** Download the `.zip` from [releases](https://github.com/leebase/init-agent/releases) and extract manually.

### Option 2: Homebrew (macOS)

```bash
brew tap leebase/init-agent
brew install init-agent
```

Update to the latest version:

```bash
brew update
brew upgrade init-agent
```

### Option 3: Download Pre-built Binary

Download manually from [GitHub releases](https://github.com/leebase/init-agent/releases):

| Platform | Architecture | Download |
|----------|-------------|----------|
| macOS (Apple Silicon) | arm64 | `init-agent-aarch64-macos.tar.gz` |
| macOS (Intel) | x86_64 | `init-agent-x86_64-macos.tar.gz` |
| Linux | x86_64 | `init-agent-x86_64-linux.tar.gz` |
| Linux | arm64 | `init-agent-aarch64-linux.tar.gz` |
| Windows | x86_64 | `init-agent-x86_64-windows.zip` |

```bash
# macOS/Linux example
curl -L -o init-agent.tar.gz https://github.com/leebase/init-agent/releases/latest/download/init-agent-aarch64-macos.tar.gz
tar xzf init-agent.tar.gz
sudo mv init-agent-aarch64-macos /usr/local/bin/init-agent
chmod +x /usr/local/bin/init-agent
```

### Option 3: Build from Source

#### Prerequisites

- [Zig](https://ziglang.org/download/) 0.15.0 or later

#### Quick Build

```bash
git clone https://github.com/yourusername/init-agent.git
cd init-agent
make build

# Install
cp zig-out/bin/init-agent ~/.local/bin/
# or
cp zig-out/bin/init-agent /usr/local/bin/
```

#### Cross-Compilation

Build for all platforms:

```bash
make release-all
```

Or specific platforms:

```bash
make release-aarch64-macos    # Apple Silicon
make release-x86_64-macos     # Intel Mac
make release-x86_64-linux     # Linux x86_64
make release-aarch64-linux    # Linux ARM64
make release-x86_64-windows   # Windows
```

Create release packages:

```bash
make package
# Creates .tar.gz (macOS/Linux) and .zip (Windows) in dist/
```

## Usage

```bash
init-agent <project-name> [options]

Options:
  --name <name>       Display name for project (default: project-name)
  --profile <name>    Project profile: python, web-app, zig-cli (default: python)
  --dir <path>        Output directory (default: ./<project-name>)
  --author <name>     Author name (default: from git config or 'Anonymous')
  --force             Overwrite existing directory
  --skip-existing     Skip existing files without prompting
  --dry-run           Preview what would be created
  --no-git            Skip git initialization
  --list              List available profiles
  --update            Update all template files in current dir (use with --profile)
  
  -h, --help          Show help
  -v, --version       Show version

Examples:
  # Python package project
  init-agent my-package --profile python

  # Zig CLI tool with custom display name
  init-agent my-cli --profile zig-cli --name "My CLI Tool" --author "Jane Doe"

  # Web app with React + Vite
  init-agent my-app --profile web-app --force

  # Update template files in an existing project
  init-agent --update --profile python

  # List all profiles
  init-agent --list
```

## Philosophy

init-agent implements the **AgentFlow** methodology for human-AI collaboration:

1. **Documentation as Interface** - Markdown files are the API between humans and AI agents
2. **Context Preservation** - `context.md` maintains state across sessions and LLMs
3. **Development Loop** - Code → Test → Test As Lee → Fix → Loop → Document → Commit
4. **Result Logging** - `result-review.md` tracks what was built and how to verify it
5. **Template Updates** - `--update` pushes template improvements to existing projects
6. **Agent Agnostic** - Works with Claude, ChatGPT, Gemini, and features native integration for Google DeepMind's Antigravity agents.

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

### Using Make

```bash
make build         # Release build
make debug         # Debug build
make test          # Run tests
make run           # Build and run test scaffold
make dev-test      # Build, test, and clean up
make clean         # Clean artifacts
make help          # Show all targets
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

## CI/CD

This project uses GitHub Actions for:

- **Continuous Integration**: Tests on every PR (Ubuntu, macOS, Windows)
- **Release Builds**: Automatic cross-platform binaries on tag push

### Creating a Release

```bash
# 1. Ensure you're on main with clean working directory
git checkout main
git status

# 2. Run the release script
./scripts/release.sh v0.1.0

# 3. GitHub Actions builds and publishes release binaries
```

### Manual Cross-Compilation

```bash
# Build all targets locally
make release-all

# Build specific target
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux
```

## Acknowledgments

Built from patterns learned in [LeeClaw](https://github.com/yourusername/leeclaw).
