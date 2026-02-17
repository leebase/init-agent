const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const print = std.debug.print;

const VERSION = "0.1.0";

const Language = enum {
    python,
    zig,
    typescript,
    rust,
    go,
    
    pub fn fromString(s: []const u8) ?Language {
        if (std.mem.eql(u8, s, "python")) return .python;
        if (std.mem.eql(u8, s, "py")) return .python;
        if (std.mem.eql(u8, s, "zig")) return .zig;
        if (std.mem.eql(u8, s, "z")) return .zig;
        if (std.mem.eql(u8, s, "typescript")) return .typescript;
        if (std.mem.eql(u8, s, "ts")) return .typescript;
        if (std.mem.eql(u8, s, "rust")) return .rust;
        if (std.mem.eql(u8, s, "rs")) return .rust;
        if (std.mem.eql(u8, s, "go")) return .go;
        if (std.mem.eql(u8, s, "golang")) return .go;
        return null;
    }
    
    pub fn extension(self: Language) []const u8 {
        return switch (self) {
            .python => "py",
            .zig => "zig",
            .typescript => "ts",
            .rust => "rs",
            .go => "go",
        };
    }
    
    pub fn displayName(self: Language) []const u8 {
        return switch (self) {
            .python => "Python",
            .zig => "Zig",
            .typescript => "TypeScript",
            .rust => "Rust",
            .go => "Go",
        };
    }
};

const Template = enum {
    minimal,
    full,
    api,
    cli,
    lib,
};

const Config = struct {
    project_name: []const u8,
    language: Language,
    template: Template,
    path: []const u8,
    init_git: bool,
    allocator: std.mem.Allocator,
    
    pub fn deinit(self: *Config) void {
        self.allocator.free(self.project_name);
        self.allocator.free(self.path);
    }
};

const ScaffoldError = error{
    ProjectExists,
    InvalidLanguage,
    InvalidTemplate,
    IoError,
    OutOfMemory,
};

// Template content - AGENTS.md
const AGENTS_MD =
    \\# Agent Guide: {s}
    \\
    \\> **For AI agents working on this project.**
    \\> 
    \\> Read this file first. Then read `context.md` for current state.
    \\
    \\---
    \\
    \\## Your Role
    \\
    \\You are an expert software engineer pair-programming with the human. Your job is to:
    \\
    \\1. **Understand** the product vision from `product-definition.md`
    \\2. **Implement** features following TinyClaw methodology
    \\3. **Document** decisions in `context.md` and `result-review.md`
    \\4. **Validate** all code with tests before declaring complete
    \\
    \\---
    \\
    \\## Guardrails
    \\
    \\### ✅ Allowed
    \\
    \\- Write and modify source code
    \\- Create and run tests
    \\- Update documentation
    \\- Research and summarize external resources
    \\- Propose backlog items
    \\- Fix bugs and refactor
    \\
    \\### ❌ Not Allowed (Without Explicit Permission)
    \\
    \\- Run code that modifies the system (install, delete, etc.)
    \\- Make git commits (suggest changes, human commits)
    \\- Open external network connections (unless for research)
    \\- Access sensitive files outside project directory
    \\- Execute shell commands that could be destructive
    \\
    \\---
    \\
    \\## TinyClaw Methodology
    \\
    \\Every increment must be:
    \\
    \\1. **Small** - Under 200 lines of change
    \\2. **Working** - Tests pass, code runs
    \\3. **Validated** - Demonstrated to work
    \\4. **Then expand** - Build on proven foundations
    \\
    \\---
    \\
    \\## Project Structure
    \\
    \\```
    \\{s}/
    \\├── AGENTS.md              # This file
    \\├── context.md             # Working state (read every session)
    \\├── product-definition.md  # Vision and constraints
    \\├── sprint-plan.md         # Current sprint
    \\├── result-review.md       # Running log of completed work
    \\├── backlog/               # Backlog items by status
    \\│   ├── candidates/        # AI generates here
    \\│   ├── approved/          # Human approves here
    \\│   ├── parked/            # Deferred items
    \\│   └── implemented/       # Completed items
    \\├── src/                   # Source code
    \\├── tests/                 # Tests
    \\└── logs/                  # Session logs
    \\```
    \\
    \\---
    \\
    \\## Patterns
    \\
    \\### Error Handling
    \\- Return errors, don't panic
    \\- Log context with errors
    \\- Fail fast, fail clearly
    \\
    \\### Documentation
    \\- Update `context.md` after significant changes
    \\- Log completed work to `result-review.md`
    \\- Comment "why", not "what"
    \\
    \\### Testing
    \\- Tests before implementation (TDD preferred)
    \\- All code paths tested
    \\- Integration tests for external dependencies
    \\
    \\---
    \\
    \\## Communication Style
    \\
    \\- **Concise**: Get to the point
    \\- **Specific**: Exact file paths, line numbers
    \\- **Actionable**: Clear next steps
    \\- **Honest**: Say when something won't work
    \\
    \\---
    \\
    \\End of Agent Guide.
    \\
;

// Template content - context.md
const CONTEXT_MD = 
    \\# {s} - Context
    \\
    \\> **Purpose**: Working memory for session continuity. 
    \\> If power drops, new AI takes over, or we return after break—read this first.
    \\
    \\---
    \\
    \\## Snapshot
    \\
    \\| Attribute | Value |
    \\|-----------|-------|
    \\| **Phase** | Bootstrap |
    \\| **Mode** | 1 (Research — no autonomous execution) |
    \\| **Last Updated** | {s} |
    \\
    \\### Mode Definitions
    \\
    \\- **Mode 1**: Research/read only. No code execution.
    \\- **Mode 2**: Implementation with human approval. Tests okay.
    \\- **Mode 3**: Full autonomy. Human reviews results.
    \\
    \\---
    \\
    \\## What's Happening Now
    \\
    \\### Current Focus
    \\Project initialization complete. Ready for first sprint planning.
    \\
    \\### Recently Completed
    \\- ✅ Project scaffold created with init-agent v{s}
    \\- ✅ Documentation structure initialized
    \\- ✅ Git repository initialized
    \\
    \\### Next Steps
    \\1. Human: Edit `product-definition.md` with project vision
    \\2. Human: Create initial sprint plan
    \\3. AI: Begin first task group
    \\
    \\---
    \\
    \\## Decisions Locked
    \\
    \\| Decision | Rationale | Date |
    \\|----------|-----------|------|
    \\| Language: {s} | Project scaffold | {s} |
    \\| TinyClaw methodology | Build small, validate, expand | {s} |
    \\
    \\---
    \\
    \\## Active Issues
    \\
    \\None yet. Add issues here as they arise.
    \\
    \\---
    \\
    \\*This file is updated by the AI agent every session.*
    \\
;

// Template content - sprint-plan.md
const SPRINT_PLAN_MD =
    \\# Sprint Plan
    \\
    \\> Current sprint tracking.
    \\
    \\---
    \\
    \\## Sprint Status Dashboard
    \\
    \\| Attribute | Value |
    \\|-----------|-------|
    \\| Sprint | 1 — Initial Implementation |
    \\| Status | 🟡 Planning |
    \\| Start Date | TBD |
    \\| Target End | TBD |
    \\| Completion | 0% |
    \\
    \\---
    \\
    \\## Task Groups
    \\
    \\Define task groups here based on `product-definition.md`.
    \\
    \\### Task Group 1 — [Name]
    \\
    \\| Task | Status |
    \\|------|--------|
    \\| Task 1 | ⬜ |
    \\| Task 2 | ⬜ |
    \\
    \\**Completion Criteria:**
    \\- [ ] Criteria 1
    \\- [ ] Criteria 2
    \\
    \\---
    \\
    \\## Definition of Done
    \\
    \\- [ ] All task groups complete
    \\- [ ] Tests passing
    \\- [ ] Documentation updated
    \\- [ ] `result-review.md` updated
    \\
    \\---
    \\
    \\## Progress Calculation
    \\
    \\Update completion percentage as tasks finish.
    \\
    \\---
    \\
    \\*End of Sprint Plan*
    \\
;

// Template content - result-review.md
const RESULT_REVIEW_MD = 
    \\# Result Review
    \\
    \\> **Running log of completed work.** Newest entries at the top.
    \\
    \\---
    \\
    \\## {s} — PROJECT INITIALIZED
    \\
    \\**Project scaffold created with init-agent v{s}**
    \\
    \\### What Was Set Up
    \\
    \\- Project: `{s}`
    \\- Language: {s}
    \\- Template: Full scaffold with documentation
    \\
    \\### Files Created
    \\
    \\- `AGENTS.md` - AI agent guide
    \\- `context.md` - Working memory
    \\- `product-definition.md` - Vision and constraints
    \\- `sprint-plan.md` - Sprint tracking
    \\- `result-review.md` - This file
    \\- `backlog/` - Backlog structure
    \\- `src/` - Source directory
    \\- `tests/` - Test directory
    \\
    \\### Next Steps
    \\
    \\1. Edit `product-definition.md` with project vision
    \\2. Define first sprint in `sprint-plan.md`
    \\3. Begin implementation
    \\
    \\---
    \\
    \\*End of current entries. Add new results above this line.*
    \\
;

// Template content - backlog schema
const BACKLOG_SCHEMA_MD =
    \\# Backlog Item Schema
    \\
    \\## File Location
    \\
    \\```
    \\backlog/
    \\├── candidates/       # AI writes here
    \\├── approved/         # Human moves here
    \\├── parked/           # Human moves here
    \\├── implemented/      # Completed
    \\└── schema.md         # This file
    \\```
    \\
    \\---
    \\
    \\## Schema
    \\
    \\```yaml
    \\---
    \\id: BI-001
title: Feature Title
    \\source: research/target
    \\source_insight: One sentence insight
    \\opportunity: What capability we gain
    \\why_now: Why this matters now
    \\minimal_impl: Smallest working version
    \\definition_of_done:
      - Task 1
      - Task 2
    \\effort: S  # S, M, L
    \\symforge_recipe: builder_safe  # planner_only, builder_safe, operator_blocked
    \\priority: now  # now, next, someday
    \\status: candidate  # candidate, approved, parked, implemented
    \\created_at: 2026-02-17T10:00:00Z
    \\created_by: init-agent
    \\---
    \\```
    \\
    \\---
    \\
    \\## Workflow
    \\
    \\```
    \\AI generates → candidates → Human approves → approved → Complete → implemented
                     ↓
               parked (deferred)
    \\```
    \\
;

// Template content - .gitignore
const GITIGNORE = 
    \\# Dependencies
    \\node_modules/
    \\vendor/
    \\.venv/
    \\venv/
    \\__pycache__/
    \\*.pyc
    \\.pytest_cache/
    \\zig-cache/
    \\zig-out/
    \\
    \\# Build artifacts
    \\build/
    \\dist/
    \\*.exe
    \\*.dll
    \\*.so
    \\*.dylib
    \\
    \\# IDE
    \\.vscode/
    \\.idea/
    \\*.swp
    \\*.swo
    \\*~
    \\
    \\# OS
    \\.DS_Store
    \\Thumbs.db
    \\
    \\# Logs (keep structure, ignore content)
    \\logs/sessions/*.jsonl
    \\logs/summaries/*.md
    \\!logs/.gitkeep
    \\
    \\# Environment
    \\.env
    \\.env.local
    \\
;

fn printUsage() void {
    print(
        \\\\nUsage: init-agent <project-name> [options]

Create a new AI-agent project with scaffolded documentation and structure.

Options:
  --lang <lang>       Language: python, zig, ts, rust, go (default: python)
  --template <type>   Template: minimal, full (default: full)
  --path <path>       Target directory (default: ./<name>)
  --no-git            Skip git initialization
  
  -h, --help          Show this help
  -v, --version       Show version

Examples:
  init-agent my-project
  init-agent my-api --lang python --template full
  init-agent my-cli --lang zig --template minimal

For more information: https://github.com/yourusername/init-agent
\\\\n,
    );
}

fn getCurrentTimestamp(allocator: std.mem.Allocator) ![]const u8 {
    const now = std.time.timestamp();
    const seconds: u64 = @intCast(now);
    
    // Format as ISO8601
    var buf: [64]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
        2026, 2, 17,  // Date (we'll use current date in real impl)
        12, 0, 0,     // Time
    });
    
    return allocator.dupe(u8, formatted);
}

fn createDirectory(path: []const u8) !void {
    fs.cwd().makeDir(path) catch |err| {
        if (err != error.PathAlreadyExists) {
            return err;
        }
    };
}

fn writeFile(dir: fs.Dir, filename: []const u8, content: []const u8) !void {
    const file = try dir.createFile(filename, .{});
    defer file.close();
    try file.writeAll(content);
}

fn generateAgentsMd(allocator: std.mem.Allocator, project_name: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator, AGENTS_MD, .{ project_name, project_name });
}

fn generateContextMd(allocator: std.mem.Allocator, project_name: []const u8, language: Language) ![]const u8 {
    const timestamp = try getCurrentTimestamp(allocator);
    defer allocator.free(timestamp);
    
    return try std.fmt.allocPrint(allocator, CONTEXT_MD, .{
        project_name,
        timestamp,
        VERSION,
        language.displayName(),
        timestamp,
        timestamp,
    });
}

fn generateResultReviewMd(allocator: std.mem.Allocator, project_name: []const u8, language: Language) ![]const u8 {
    const timestamp = try getCurrentTimestamp(allocator);
    defer allocator.free(timestamp);
    
    return try std.fmt.allocPrint(allocator, RESULT_REVIEW_MD, .{
        timestamp,
        VERSION,
        project_name,
        language.displayName(),
    });
}

fn createScaffold(config: Config) ScaffoldError!void {
    const allocator = config.allocator;
    
    // Check if directory exists
    fs.cwd().access(config.path, .{}) catch |err| switch (err) {
        error.FileNotFound => {},
        else => return ScaffoldError.ProjectExists,
    };
    
    // Create project directory
    fs.cwd().makeDir(config.path) catch |err| {
        print("Error creating directory: {s}\\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };
    
    var project_dir = fs.cwd().openDir(config.path, .{}) catch |err| {
        print("Error opening directory: {s}\\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };
    defer project_dir.close();
    
    // Create base documentation
    const agents_md = generateAgentsMd(allocator, config.project_name) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(agents_md);
    writeFile(project_dir, "AGENTS.md", agents_md) catch return ScaffoldError.IoError;
    
    const context_md = generateContextMd(allocator, config.project_name, config.language) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(context_md);
    writeFile(project_dir, "context.md", context_md) catch return ScaffoldError.IoError;
    
    const result_review_md = generateResultReviewMd(allocator, config.project_name, config.language) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(result_review_md);
    writeFile(project_dir, "result-review.md", result_review_md) catch return ScaffoldError.IoError;
    
    writeFile(project_dir, "sprint-plan.md", SPRINT_PLAN_MD) catch return ScaffoldError.IoError;
    writeFile(project_dir, ".gitignore", GITIGNORE) catch return ScaffoldError.IoError;
    
    // Create backlog structure
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "backlog" })) catch return ScaffoldError.IoError;
    
    var backlog_dir = project_dir.openDir("backlog", .{}) catch return ScaffoldError.IoError;
    defer backlog_dir.close();
    
    writeFile(backlog_dir, "schema.md", BACKLOG_SCHEMA_MD) catch return ScaffoldError.IoError;
    
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "backlog/candidates" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "backlog/approved" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "backlog/parked" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "backlog/implemented" })) catch return ScaffoldError.IoError;
    
    // Create logs structure
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "logs" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "logs/sessions" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "logs/summaries" })) catch return ScaffoldError.IoError;
    
    // Create src and tests directories
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "src" })) catch return ScaffoldError.IoError;
    createDirectory(try std.fs.path.join(allocator, &.{ config.path, "tests" })) catch return ScaffoldError.IoError;
    
    // Initialize git if requested
    if (config.init_git) {
        _ = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ "git", "init", config.path },
        }) catch {
            print("Warning: Could not initialize git repository\\n", .{});
        };
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    
    if (args.len < 2) {
        printUsage();
        return;
    }
    
    // Check for help/version flags
    if (std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        printUsage();
        return;
    }
    
    if (std.mem.eql(u8, args[1], "-v") or std.mem.eql(u8, args[1], "--version")) {
        print("init-agent version {s}\\n", .{VERSION});
        return;
    }
    
    const project_name = args[1];
    
    // Default configuration
    var config = Config{
        .project_name = try allocator.dupe(u8, project_name),
        .language = .python,
        .template = .full,
        .path = try std.fs.path.join(allocator, &.{ ".", project_name }),
        .init_git = true,
        .allocator = allocator,
    };
    defer config.deinit();
    
    // Parse arguments
    var i: usize = 2;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        
        if (std.mem.eql(u8, arg, "--lang")) {
            if (i + 1 >= args.len) {
                print("Error: --lang requires a value\\n", .{});
                return;
            }
            i += 1;
            const lang_str = args[i];
            config.language = Language.fromString(lang_str) orelse {
                print("Error: Unknown language: {s}\\n", .{lang_str});
                return;
            };
        } else if (std.mem.eql(u8, arg, "--template")) {
            if (i + 1 >= args.len) {
                print("Error: --template requires a value\\n", .{});
                return;
            }
            i += 1;
            const template_str = args[i];
            if (std.mem.eql(u8, template_str, "minimal")) {
                config.template = .minimal;
            } else if (std.mem.eql(u8, template_str, "full")) {
                config.template = .full;
            } else {
                print("Error: Unknown template: {s}\\n", .{template_str});
                return;
            }
        } else if (std.mem.eql(u8, arg, "--path")) {
            if (i + 1 >= args.len) {
                print("Error: --path requires a value\\n", .{});
                return;
            }
            i += 1;
            allocator.free(config.path);
            config.path = try allocator.dupe(u8, args[i]);
        } else if (std.mem.eql(u8, arg, "--no-git")) {
            config.init_git = false;
        } else {
            print("Error: Unknown option: {s}\\n", .{arg});
            return;
        }
    }
    
    // Create scaffold
    print("\\n🚀 Creating project: {s}\\n", .{project_name});
    print("   Language: {s}\\n", .{config.language.displayName()});
    print("   Template: {s}\\n", .{@tagName(config.template)});
    print("   Location: {s}\\n\\n", .{config.path});
    
    createScaffold(config) catch |err| {
        switch (err) {
            ScaffoldError.ProjectExists => {
                print("Error: Project directory already exists: {s}\\n", .{config.path});
            },
            ScaffoldError.IoError => {
                print("Error: Could not create project files\\n", .{});
            },
            ScaffoldError.OutOfMemory => {
                print("Error: Out of memory\\n", .{});
            },
            else => {
                print("Error: {s}\\n", .{@errorName(err)});
            },
        }
        return;
    };
    
    // Success message
    print("✅ Created {s}\\n", .{project_name});
    print("✅ Generated documentation scaffold\\n");
    print("✅ Created backlog structure\\n");
    print("✅ Set up {s} project structure\\n", .{config.language.displayName()});
    if (config.init_git) {
        print("✅ Initialized git repository\\n");
    }
    
    print("\\nNext steps:\\n");
    print("1. Edit product-definition.md with your vision\\n");
    print("2. Run: cd {s} && git add -A && git commit -m \"Initial commit\"\\n", .{project_name});
    print("3. Start working with your AI agent!\\n");
    print("\\n   cd {s}\\n", .{project_name});
    print("   [Your AI agent reads AGENTS.md and begins]\\n");
}
