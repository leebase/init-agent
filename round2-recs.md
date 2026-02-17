
What init-agent is

A repo/project scaffolder that writes a standardized “agent kit” into the current directory (or a target dir):
	•	agent.md (your execution contract / operating protocol)
	•	product-definition.md (template or prompt scaffold)
	•	architecture.md
	•	sprint-plan.md, sprint-review.md, lees-process.md, WHERE_AM_I.md
	•	optionally .gitignore, README.md, etc.

Later it becomes a profiled scaffolder:
	•	init-agent --python → python project kit + agent contract tuned for Python
	•	init-agent --web-app → web app kit + agent contract tuned for web stack
	•	etc.

⸻

Architecture that satisfies “baked in, not read at runtime”

You want to embed text files at compile time.

If you build init-agent in Zig (recommended since you’re already there)

Use @embedFile("templates/common/agent.md") style embedding, then write those bytes to disk at runtime.

Key pattern
	•	templates live in repo under templates/...
	•	build bakes them into the binary
	•	binary writes them out based on chosen profile

This gives you: no runtime file dependency + reproducible output.

Alternative languages

Same idea exists:
	•	Go: //go:embed
	•	Rust: include_str!

But given your current momentum, Zig is a great fit for “one binary everywhere”.

⸻

Template selection model (the thing that keeps this from getting messy)

Think of templates as:
	•	Profiles (python, web-app, zig-cli, data-pipeline, etc.)
	•	Each profile = list of files to generate
	•	Each file = embedded string + optional placeholder substitution

Suggested layout

templates/
  common/
    agent.md
    lees-process.md
    WHERE_AM_I.md
    sprint-plan.md
    sprint-review.md
  python/
    README.md
    pyproject.toml
    src/__init__.py
  web-app/
    README.md
    package.json
    src/
  zig-cli/
    README.md
    build.zig
    src/main.zig

And a registry in code like:
	•	profile name → list of template “assets” to emit

⸻

Placeholders (you will want these immediately)

Even in v1, you’ll want tokens like:
	•	{{PROJECT_NAME}}
	•	{{DATE}}
	•	{{AUTHOR}}
	•	{{PROFILE}}

Start with the simplest substitution engine:
	•	scan and replace exact tokens
	•	no fancy templating language needed

Keep it deterministic.

⸻

CLI UX proposal

v1 commands
	•	init-agent → writes “common” kit
	•	init-agent --profile python (or --python) → adds python kit on top of common
	•	init-agent --list → list available profiles
	•	init-agent --dir path → output directory
	•	init-agent --force → overwrite files

v2 additions
	•	init-agent --dry-run (prints what it would write)
	•	init-agent --name Foo sets {{PROJECT_NAME}}

⸻

Cross-platform packaging plan (practical)
	•	Build per target in CI:
	•	macOS (x86_64 + arm64 ideally)
	•	Windows (x86_64)
	•	Linux (x86_64)
	•	Output a release zip per platform.

Zig is good at cross-compiling, but “build on each OS” is the least painful route early. Cross compile later once stable.

⸻

Implementation milestones (no drama, just shipping)

Sprint 0: Skeleton
	•	init-agent prints help and version
	•	--list returns profiles from registry

Sprint 1: Generate common kit
	•	Embedded templates for common/*
	•	Writes files to disk
	•	--dir, --force

Sprint 2: Profiles
	•	Add --python and --web-app as first two profiles
	•	Profile overlays common

Sprint 3: Substitution
	•	--name, --author
	•	Replace placeholders in output

Sprint 4: Release pipeline
	•	GitHub Actions builds artifacts for mac/win/linux
	•	Version stamping

⸻

The “init-agent” operating contract (what to tell the agent)

Here’s the planning prompt you asked for — give this to your init-agent-building model:

init-agent Planning + Execution Prompt

Build a cross-platform CLI tool named init-agent (macOS/Windows/Linux).

Requirements:
	•	Templates are embedded into the binary at compile-time (not read at runtime).
	•	By default, generate a “common agent kit” into the target directory: agent.md, WHERE_AM_I.md, lees-process.md, sprint-plan.md, sprint-review.md, product-definition.md, architecture.md.
	•	Add profiles selectable by flags: --python and --web-app (minimum) that layer additional templates on top.
	•	Support --list, --dir <path>, and --force overwrite protection.
	•	Add placeholder substitution for {{PROJECT_NAME}}, {{DATE}}, {{PROFILE}}.

Deliverables:
	•	Repo layout with templates/ directory.
	•	Source code with a profile registry.
	•	Tests for placeholder substitution and file overwrite rules.
	•	README with install/build/run instructions.

Execution protocol:
	•	Plan → implement → test → fix until green → update docs → commit per sprint.
	•	If blocked, ask for a single concise list of missing inputs.
