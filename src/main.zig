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

// Embedded templates
const AGENTS_MD = @embedFile("templates/base/AGENTS.md");
const CONTEXT_MD = @embedFile("templates/base/context.md");
const RESULT_REVIEW_MD = @embedFile("templates/base/result-review.md");
const SPRINT_PLAN_MD = @embedFile("templates/base/sprint-plan.md");
const BACKLOG_SCHEMA_MD = @embedFile("templates/base/backlog-schema.md");

const GITIGNORE = 
    "# Dependencies\n" ++
    "node_modules/\n" ++
    "vendor/\n" ++
    ".venv/\n" ++
    "venv/\n" ++
    "__pycache__/\n" ++
    "*.pyc\n" ++
    ".pytest_cache/\n" ++
    "zig-cache/\n" ++
    "zig-out/\n" ++
    "\n" ++
    "# Build artifacts\n" ++
    "build/\n" ++
    "dist/\n" ++
    "*.exe\n" ++
    "*.dll\n" ++
    "*.so\n" ++
    "*.dylib\n" ++
    "\n" ++
    "# IDE\n" ++
    ".vscode/\n" ++
    ".idea/\n" ++
    "*.swp\n" ++
    "*.swo\n" ++
    "*~\n" ++
    "\n" ++
    "# OS\n" ++
    ".DS_Store\n" ++
    "Thumbs.db\n" ++
    "\n" ++
    "# Logs\n" ++
    "logs/sessions/*.jsonl\n" ++
    "logs/summaries/*.md\n" ++
    "!logs/.gitkeep\n" ++
    "\n" ++
    "# Environment\n" ++
    ".env\n" ++
    ".env.local\n";

fn printUsage() void {
    print("Usage: init-agent <project-name> [options]\n\n", .{});
    print("Create a new AI-agent project with scaffolded documentation and structure.\n\n", .{});
    print("Options:\n", .{});
    print("  --lang <lang>       Language: python, zig, ts, rust, go (default: python)\n", .{});
    print("  --template <type>   Template: minimal, full (default: full)\n", .{});
    print("  --path <path>       Target directory (default: ./<name>)\n", .{});
    print("  --no-git            Skip git initialization\n", .{});
    print("  -h, --help          Show this help\n", .{});
    print("  -v, --version       Show version\n\n", .{});
    print("Examples:\n", .{});
    print("  init-agent my-project\n", .{});
    print("  init-agent my-api --lang python --template full\n", .{});
    print("  init-agent my-cli --lang zig --template minimal\n\n", .{});
    print("For more information: https://github.com/yourusername/init-agent\n", .{});
}

fn getCurrentTimestamp(allocator: std.mem.Allocator) ![]const u8 {
    const now = std.time.timestamp();
    const seconds: u64 = @intCast(now);
    
    // Format as ISO8601 (simplified)
    var buf: [64]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
        2026, 2, 17,
        @mod(seconds / 3600, 24),
        @mod(seconds / 60, 60),
        @mod(seconds, 60),
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

fn replaceAll(allocator: std.mem.Allocator, content: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
    // Count occurrences
    var count: usize = 0;
    var i: usize = 0;
    while (i < content.len) {
        if (std.mem.startsWith(u8, content[i..], needle)) {
            count += 1;
            i += needle.len;
        } else {
            i += 1;
        }
    }
    
    if (count == 0) {
        return allocator.dupe(u8, content);
    }
    
    // Calculate new size
    const new_len = content.len - (count * needle.len) + (count * replacement.len);
    var result = try allocator.alloc(u8, new_len);
    errdefer allocator.free(result);
    
    // Replace
    var src_idx: usize = 0;
    var dst_idx: usize = 0;
    while (src_idx < content.len) {
        if (std.mem.startsWith(u8, content[src_idx..], needle)) {
            @memcpy(result[dst_idx..dst_idx + replacement.len], replacement);
            dst_idx += replacement.len;
            src_idx += needle.len;
        } else {
            result[dst_idx] = content[src_idx];
            dst_idx += 1;
            src_idx += 1;
        }
    }
    
    return result;
}

fn processTemplate(allocator: std.mem.Allocator, template: []const u8, project_name: []const u8, language: Language, timestamp: []const u8, version: []const u8) ![]const u8 {
    var result = try allocator.dupe(u8, template);
    errdefer allocator.free(result);
    
    // Replace placeholders
    const replacements = .{
        .{ "{PROJECT_NAME}", project_name },
        .{ "{LANGUAGE}", language.displayName() },
        .{ "{TIMESTAMP}", timestamp },
        .{ "{VERSION}", version },
    };
    
    inline for (replacements) |replacement| {
        const new_result = try replaceAll(allocator, result, replacement[0], replacement[1]);
        allocator.free(result);
        result = new_result;
    }
    
    return result;
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
        print("Error creating directory: {s}\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };
    
    var project_dir = fs.cwd().openDir(config.path, .{}) catch |err| {
        print("Error opening directory: {s}\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };
    defer project_dir.close();
    
    // Get timestamp
    const timestamp = getCurrentTimestamp(allocator) catch "2026-02-17T00:00:00Z";
    defer allocator.free(timestamp);
    
    // Process and write templates
    const agents_md = processTemplate(allocator, AGENTS_MD, config.project_name, config.language, timestamp, VERSION) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(agents_md);
    writeFile(project_dir, "AGENTS.md", agents_md) catch return ScaffoldError.IoError;
    
    const context_md = processTemplate(allocator, CONTEXT_MD, config.project_name, config.language, timestamp, VERSION) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(context_md);
    writeFile(project_dir, "context.md", context_md) catch return ScaffoldError.IoError;
    
    const result_review_md = processTemplate(allocator, RESULT_REVIEW_MD, config.project_name, config.language, timestamp, VERSION) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(result_review_md);
    writeFile(project_dir, "result-review.md", result_review_md) catch return ScaffoldError.IoError;
    
    writeFile(project_dir, "sprint-plan.md", SPRINT_PLAN_MD) catch return ScaffoldError.IoError;
    writeFile(project_dir, ".gitignore", GITIGNORE) catch return ScaffoldError.IoError;
    
    // Create backlog structure
    const backlog_path = std.fs.path.join(allocator, &.{ config.path, "backlog" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(backlog_path);
    createDirectory(backlog_path) catch return ScaffoldError.IoError;
    
    var backlog_dir = project_dir.openDir("backlog", .{}) catch return ScaffoldError.IoError;
    defer backlog_dir.close();
    
    writeFile(backlog_dir, "schema.md", BACKLOG_SCHEMA_MD) catch return ScaffoldError.IoError;
    
    const candidates_path = std.fs.path.join(allocator, &.{ config.path, "backlog", "candidates" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(candidates_path);
    createDirectory(candidates_path) catch return ScaffoldError.IoError;
    
    const approved_path = std.fs.path.join(allocator, &.{ config.path, "backlog", "approved" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(approved_path);
    createDirectory(approved_path) catch return ScaffoldError.IoError;
    
    const parked_path = std.fs.path.join(allocator, &.{ config.path, "backlog", "parked" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(parked_path);
    createDirectory(parked_path) catch return ScaffoldError.IoError;
    
    const implemented_path = std.fs.path.join(allocator, &.{ config.path, "backlog", "implemented" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(implemented_path);
    createDirectory(implemented_path) catch return ScaffoldError.IoError;
    
    // Create logs structure
    const logs_path = std.fs.path.join(allocator, &.{ config.path, "logs" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(logs_path);
    createDirectory(logs_path) catch return ScaffoldError.IoError;
    
    const sessions_path = std.fs.path.join(allocator, &.{ config.path, "logs", "sessions" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(sessions_path);
    createDirectory(sessions_path) catch return ScaffoldError.IoError;
    
    const summaries_path = std.fs.path.join(allocator, &.{ config.path, "logs", "summaries" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(summaries_path);
    createDirectory(summaries_path) catch return ScaffoldError.IoError;
    
    // Create src and tests directories
    const src_path = std.fs.path.join(allocator, &.{ config.path, "src" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(src_path);
    createDirectory(src_path) catch return ScaffoldError.IoError;
    
    const tests_path = std.fs.path.join(allocator, &.{ config.path, "tests" }) catch return ScaffoldError.OutOfMemory;
    defer allocator.free(tests_path);
    createDirectory(tests_path) catch return ScaffoldError.IoError;
    
    // Initialize git if requested
    if (config.init_git) {
        _ = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ "git", "init", config.path },
        }) catch {
            print("Warning: Could not initialize git repository\n", .{});
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
        print("init-agent version {s}\n", .{VERSION});
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
                print("Error: --lang requires a value\n", .{});
                return;
            }
            i += 1;
            const lang_str = args[i];
            config.language = Language.fromString(lang_str) orelse {
                print("Error: Unknown language: {s}\n", .{lang_str});
                return;
            };
        } else if (std.mem.eql(u8, arg, "--template")) {
            if (i + 1 >= args.len) {
                print("Error: --template requires a value\n", .{});
                return;
            }
            i += 1;
            const template_str = args[i];
            if (std.mem.eql(u8, template_str, "minimal")) {
                config.template = .minimal;
            } else if (std.mem.eql(u8, template_str, "full")) {
                config.template = .full;
            } else {
                print("Error: Unknown template: {s}\n", .{template_str});
                return;
            }
        } else if (std.mem.eql(u8, arg, "--path")) {
            if (i + 1 >= args.len) {
                print("Error: --path requires a value\n", .{});
                return;
            }
            i += 1;
            allocator.free(config.path);
            config.path = try allocator.dupe(u8, args[i]);
        } else if (std.mem.eql(u8, arg, "--no-git")) {
            config.init_git = false;
        } else {
            print("Error: Unknown option: {s}\n", .{arg});
            return;
        }
    }
    
    // Create scaffold
    print("\n🚀 Creating project: {s}\n", .{project_name});
    print("   Language: {s}\n", .{config.language.displayName()});
    print("   Template: {s}\n", .{@tagName(config.template)});
    print("   Location: {s}\n\n", .{config.path});
    
    createScaffold(config) catch |err| {
        switch (err) {
            ScaffoldError.ProjectExists => {
                print("Error: Project directory already exists: {s}\n", .{config.path});
            },
            ScaffoldError.IoError => {
                print("Error: Could not create project files\n", .{});
            },
            ScaffoldError.OutOfMemory => {
                print("Error: Out of memory\n", .{});
            },
            else => {
                print("Error: {s}\n", .{@errorName(err)});
            },
        }
        return;
    };
    
    // Success message
    print("✅ Created {s}\n", .{project_name});
    print("✅ Generated documentation scaffold\n", .{});
    print("✅ Created backlog structure\n", .{});
    print("✅ Set up {s} project structure\n", .{config.language.displayName()});
    if (config.init_git) {
        print("✅ Initialized git repository\n", .{});
    }
    
    print("\nNext steps:\n", .{});
    print("1. Edit product-definition.md with your vision\n", .{});
    print("2. Run: cd {s} && git add -A && git commit -m \"Initial commit\"\n", .{project_name});
    print("3. Start working with your AI agent!\n", .{});
    print("\n   cd {s}\n", .{project_name});
    print("   [Your AI agent reads AGENTS.md and begins]\n", .{});
}
