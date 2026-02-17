# Agent Guide: init-agent

> **For AI agents working on the init-agent project.**
>
> This is a meta-project - a tool that creates scaffolding for other AI-agent projects.
> Read this file first, then read `context.md` for current state.

---

## Your Role

You are building `init-agent`, a Zig CLI tool that bootstraps AI-agent projects with battle-tested patterns from LeeClaw. This is a **meta-project** - the output of this project helps humans and AIs collaborate on OTHER projects.

### Key Responsibility

Capture the essence of what made LeeClaw successful into a reusable, one-command tool.

---

## Guardrails

### ✅ Allowed

- Write Zig code (this project is Zig-only)
- Create and modify templates
- Add language support
- Write tests for Zig code
- Update documentation
- Research other scaffolding tools

### ❌ Not Allowed (Without Explicit Permission)

- Add runtime dependencies to the binary
- Require network access for core functionality
- Break backward compatibility without versioning
- Make templates language-specific when they should be generic

---

## TinyClaw Methodology

Every increment must be:

1. **Small** - Under 200 lines of Zig
2. **Working** - Compiles, passes tests, CLI works
3. **Validated** - Demonstrated with example output
4. **Then expand** - Build on proven foundations

---

## Project Structure

```
init-agent/
├── AGENTS.md              # This file
├── context.md             # Working state
├── product-definition.md  # Vision and scope
├── result-review.md       # Running log
├── build.zig              # Zig build config
├── src/
│   └── main.zig          # CLI implementation
├── templates/
│   ├── base/             # Language-agnostic templates
│   ├── python/           # Python-specific
│   ├── zig/              # Zig-specific
│   └── ...               # Other languages
└── tests/                # Zig tests
```

---

## Template System

Templates are **embedded strings** in the Zig source (for now) to keep the binary self-contained.

### Template Categories

1. **Base** (`templates/base/`)
   - Language-agnostic: AGENTS.md, context.md, sprint-plan.md, backlog/schema.md

2. **Language-specific** (`templates/<lang>/`)
   - build configs, dependency files, hello-world examples

### Template Variables

Use `{s}` for string interpolation:

```zig
const TEMPLATE = 
    \\# {s}
    \\
    \\Welcome to {s}!
    \\;

// Later:
try std.fmt.allocPrint(allocator, TEMPLATE, .{ title, project_name });
```

---

## Language Support

Current roadmap:

| Language | Status | Priority |
|----------|--------|----------|
| Python   | Planned | P0 |
| Zig      | Planned | P0 |
| TypeScript | Planned | P1 |
| Rust     | Planned | P1 |
| Go       | Planned | P2 |

### Adding a Language

1. Add to `Language` enum in `main.zig`
2. Add `.fromString()` case
3. Add `.extension()` and `.displayName()` cases
4. Create `templates/<lang>/` directory
5. Add language-specific scaffold logic
6. Add tests
7. Update documentation

---

## Error Handling

- Return errors, don't panic
- Use `ScaffoldError` enum for domain errors
- Print helpful error messages
- Exit with appropriate codes

---

## Testing

```bash
# Run tests
zig build test

# Run with example
zig build run -- my-test-project --lang python

# Check it works
ls my-test-project/
cat my-test-project/AGENTS.md
```

---

## Communication Style

- **Concise**: Zig code should be clear and idiomatic
- **Specific**: File paths, template names, line numbers
- **Actionable**: Clear next steps
- **Honest**: Say when something won't work in Zig

---

## Zig Best Practices

- Use `std.heap.GeneralPurposeAllocator` for main allocator
- Defer cleanup: `defer allocator.free(ptr)`
- Use `catch` for error handling at boundaries
- Prefer explicit error sets
- Use comptime when appropriate for templates

---

End of Agent Guide.
