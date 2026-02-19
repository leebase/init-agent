const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const print = std.debug.print;

// Import build options for version (set at build time from git tags)
const build_options = @import("build_options");
const VERSION = build_options.version;

// =============================================================================
// ANSI Colors
// =============================================================================

const Color = struct {
    const reset = "\x1b[0m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const cyan = "\x1b[36m";
    const bold = "\x1b[1m";
};

var g_color_enabled: bool = true;

fn initColorSupport() void {
    if (std.process.getEnvVarOwned(std.heap.page_allocator, "NO_COLOR")) |_| {
        g_color_enabled = false;
    } else |_| {}
}

fn cprint(color: []const u8, comptime fmt: []const u8, args: anytype) void {
    if (g_color_enabled) {
        print("{s}" ++ fmt ++ "{s}", .{color} ++ args ++ .{Color.reset});
    } else {
        print(fmt, args);
    }
}

// =============================================================================
// File Action Enum for Smart Overwrite
// =============================================================================

const FileAction = enum {
    overwrite, // Write the file
    skip, // Skip this file
    overwrite_all, // Write all remaining
    skip_all, // Skip all remaining
    show_diff, // Show diff (if possible)
    quit, // Abort
};

// Global state for batch decisions during scaffolding
var g_overwrite_all: bool = false;
var g_skip_all: bool = false;

// =============================================================================
// Profile Registry
// =============================================================================

/// A single template file with its target path and content
const TemplateFile = struct {
    /// Target path in the output project (supports {{PROJECT_NAME}} substitution)
    target_path: []const u8,
    /// File content (embedded at compile time)
    content: []const u8,
};

const Profile = struct {
    name: []const u8,
    display_name: []const u8,
    description: []const u8,
    files: []const TemplateFile,
    directories: []const []const u8,
};

// =============================================================================
// Embedded Templates - Common Files
// =============================================================================

const COMMON_AGENT_MD = @embedFile("templates/common/agent.md");
const COMMON_WHERE_AM_I_MD = @embedFile("templates/common/WHERE_AM_I.md");
const COMMON_FEEDBACK_MD = @embedFile("templates/common/feedback.md");
const COMMON_CONTEXT_MD = @embedFile("templates/common/context.md");
const COMMON_RESULT_REVIEW_MD = @embedFile("templates/common/result-review.md");
const COMMON_PROJECT_PLAN_MD = @embedFile("templates/common/project-plan.md");
const COMMON_BACKLOG_SCHEMA_MD = @embedFile("templates/common/backlog-schema.md");
const COMMON_BACKLOG_TEMPLATE_MD = @embedFile("templates/common/backlog-template.md");
const COMMON_LEES_PROCESS_MD = @embedFile("templates/common/lees-process.md");
const COMMON_SPRINT_REVIEW_MD = @embedFile("templates/common/sprint-review.md");

// =============================================================================
// Embedded Templates - Python Profile
// =============================================================================

const PYTHON_README_MD = @embedFile("templates/python/README.md");
const PYTHON_PYPROJECT_TOML = @embedFile("templates/python/pyproject.toml");
const PYTHON_SRC_INIT_PY = @embedFile("templates/python/src/{{PROJECT_NAME}}/__init__.py");
const PYTHON_SRC_MAIN_PY = @embedFile("templates/python/src/{{PROJECT_NAME}}/main.py");

// =============================================================================
// Embedded Templates - Web App Profile
// =============================================================================

const WEBAPP_README_MD = @embedFile("templates/web-app/README.md");
const WEBAPP_PACKAGE_JSON = @embedFile("templates/web-app/package.json");
const WEBAPP_TSCONFIG_JSON = @embedFile("templates/web-app/tsconfig.json");
const WEBAPP_TSCONFIG_NODE_JSON = @embedFile("templates/web-app/tsconfig.node.json");
const WEBAPP_VITE_CONFIG_TS = @embedFile("templates/web-app/vite.config.ts");
const WEBAPP_INDEX_HTML = @embedFile("templates/web-app/index.html");
const WEBAPP_SRC_MAIN_TSX = @embedFile("templates/web-app/src/main.tsx");

// =============================================================================
// Embedded Templates - Zig CLI Profile
// =============================================================================

const ZIGCLI_README_MD = @embedFile("templates/zig-cli/README.md");
const ZIGCLI_BUILD_ZIG = @embedFile("templates/zig-cli/build.zig");
const ZIGCLI_SRC_MAIN_ZIG = @embedFile("templates/zig-cli/src/main.zig");

// =============================================================================
// Profile Definitions
// =============================================================================

const PYTHON_PROFILE = Profile{
    .name = "python",
    .display_name = "Python Package",
    .description = "Python package with pyproject.toml, src layout, and tooling",
    .files = &[_]TemplateFile{
        .{ .target_path = "AGENTS.md", .content = COMMON_AGENT_MD },
        .{ .target_path = "WHERE_AM_I.md", .content = COMMON_WHERE_AM_I_MD },
        .{ .target_path = "feedback.md", .content = COMMON_FEEDBACK_MD },
        .{ .target_path = "context.md", .content = COMMON_CONTEXT_MD },
        .{ .target_path = "result-review.md", .content = COMMON_RESULT_REVIEW_MD },
        .{ .target_path = "project-plan.md", .content = COMMON_PROJECT_PLAN_MD },
        .{ .target_path = "lees-process.md", .content = COMMON_LEES_PROCESS_MD },
        .{ .target_path = "sprint-review.md", .content = COMMON_SPRINT_REVIEW_MD },
        .{ .target_path = "backlog/schema.md", .content = COMMON_BACKLOG_SCHEMA_MD },
        .{ .target_path = "backlog/template.md", .content = COMMON_BACKLOG_TEMPLATE_MD },
        .{ .target_path = "README.md", .content = PYTHON_README_MD },
        .{ .target_path = "pyproject.toml", .content = PYTHON_PYPROJECT_TOML },
        .{ .target_path = "src/{{PROJECT_NAME}}/__init__.py", .content = PYTHON_SRC_INIT_PY },
        .{ .target_path = "src/{{PROJECT_NAME}}/main.py", .content = PYTHON_SRC_MAIN_PY },
    },
    .directories = &[_][]const u8{
        "src/{{PROJECT_NAME}}",
        "tests",
        "backlog/candidates",
        "backlog/approved",
        "backlog/parked",
        "backlog/implemented",
    },
};

const WEBAPP_PROFILE = Profile{
    .name = "web-app",
    .display_name = "Web Application (React + Vite)",
    .description = "Modern web app with React, TypeScript, and Vite",
    .files = &[_]TemplateFile{
        .{ .target_path = "AGENTS.md", .content = COMMON_AGENT_MD },
        .{ .target_path = "WHERE_AM_I.md", .content = COMMON_WHERE_AM_I_MD },
        .{ .target_path = "feedback.md", .content = COMMON_FEEDBACK_MD },
        .{ .target_path = "context.md", .content = COMMON_CONTEXT_MD },
        .{ .target_path = "result-review.md", .content = COMMON_RESULT_REVIEW_MD },
        .{ .target_path = "project-plan.md", .content = COMMON_PROJECT_PLAN_MD },
        .{ .target_path = "lees-process.md", .content = COMMON_LEES_PROCESS_MD },
        .{ .target_path = "sprint-review.md", .content = COMMON_SPRINT_REVIEW_MD },
        .{ .target_path = "backlog/schema.md", .content = COMMON_BACKLOG_SCHEMA_MD },
        .{ .target_path = "backlog/template.md", .content = COMMON_BACKLOG_TEMPLATE_MD },
        .{ .target_path = "README.md", .content = WEBAPP_README_MD },
        .{ .target_path = "package.json", .content = WEBAPP_PACKAGE_JSON },
        .{ .target_path = "tsconfig.json", .content = WEBAPP_TSCONFIG_JSON },
        .{ .target_path = "tsconfig.node.json", .content = WEBAPP_TSCONFIG_NODE_JSON },
        .{ .target_path = "vite.config.ts", .content = WEBAPP_VITE_CONFIG_TS },
        .{ .target_path = "index.html", .content = WEBAPP_INDEX_HTML },
        .{ .target_path = "src/main.tsx", .content = WEBAPP_SRC_MAIN_TSX },
    },
    .directories = &[_][]const u8{
        "src",
        "public",
        "backlog/candidates",
        "backlog/approved",
        "backlog/parked",
        "backlog/implemented",
    },
};

const ZIGCLI_PROFILE = Profile{
    .name = "zig-cli",
    .display_name = "Zig CLI Tool",
    .description = "Command-line tool built with Zig",
    .files = &[_]TemplateFile{
        .{ .target_path = "AGENTS.md", .content = COMMON_AGENT_MD },
        .{ .target_path = "WHERE_AM_I.md", .content = COMMON_WHERE_AM_I_MD },
        .{ .target_path = "feedback.md", .content = COMMON_FEEDBACK_MD },
        .{ .target_path = "context.md", .content = COMMON_CONTEXT_MD },
        .{ .target_path = "result-review.md", .content = COMMON_RESULT_REVIEW_MD },
        .{ .target_path = "project-plan.md", .content = COMMON_PROJECT_PLAN_MD },
        .{ .target_path = "lees-process.md", .content = COMMON_LEES_PROCESS_MD },
        .{ .target_path = "sprint-review.md", .content = COMMON_SPRINT_REVIEW_MD },
        .{ .target_path = "backlog/schema.md", .content = COMMON_BACKLOG_SCHEMA_MD },
        .{ .target_path = "backlog/template.md", .content = COMMON_BACKLOG_TEMPLATE_MD },
        .{ .target_path = "README.md", .content = ZIGCLI_README_MD },
        .{ .target_path = "build.zig", .content = ZIGCLI_BUILD_ZIG },
        .{ .target_path = "src/main.zig", .content = ZIGCLI_SRC_MAIN_ZIG },
    },
    .directories = &[_][]const u8{
        "src",
        "backlog/candidates",
        "backlog/approved",
        "backlog/parked",
        "backlog/implemented",
    },
};

fn getProfile(name: []const u8) ?Profile {
    if (mem.eql(u8, name, "python")) {
        return PYTHON_PROFILE;
    } else if (mem.eql(u8, name, "web-app")) {
        return WEBAPP_PROFILE;
    } else if (mem.eql(u8, name, "zig-cli")) {
        return ZIGCLI_PROFILE;
    }
    return null;
}

// =============================================================================
// Configuration and Errors
// =============================================================================

const Config = struct {
    project_name: []const u8,
    display_name: []const u8,
    profile_name: []const u8,
    output_dir: []const u8,
    force: bool,
    skip_existing: bool,
    init_git: bool,
    author: []const u8,
    dry_run: bool,
    verbose: bool,
    interactive: bool,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Config) void {
        self.allocator.free(self.project_name);
        self.allocator.free(self.display_name);
        self.allocator.free(self.output_dir);
        self.allocator.free(self.author);
    }

    pub fn logVerbose(self: Config, comptime fmt: []const u8, args: anytype) void {
        if (self.verbose) {
            print("[verbose] " ++ fmt, args);
        }
    }
};

const ScaffoldError = error{
    ProjectExists,
    InvalidProfile,
    InvalidProjectName,
    IoError,
    OutOfMemory,
    UserAborted,
};

// =============================================================================
// Utility Functions
// =============================================================================

fn printUsage() void {
    print("init-agent {s} - Scaffold AI-agent projects with layered profiles\n\n", .{VERSION});
    print("Usage:\n", .{});
    print("  init-agent <project-name> [options]\n\n", .{});
    print("Options:\n", .{});
    print("  --name <name>       Display name for the project (default: project-name)\n", .{});
    print("  --profile <name>    Project profile: python, web-app, zig-cli (default: python)\n", .{});
    print("  --dir <path>        Output directory (default: ./<project-name>)\n", .{});
    print("  --author <name>     Author name (default: from git config or 'Anonymous')\n", .{});
    print("  --force             Overwrite existing files (no prompt)\n", .{});
    print("  --skip-existing     Skip existing files without prompting\n", .{});
    print("  --dry-run           Print what would be created without creating files\n", .{});
    print("  --verbose           Show detailed logging\n", .{});
    print("  --interactive       Prompt for missing values interactively\n", .{});
    print("  --no-git            Skip git initialization\n", .{});
    print("  --list              List available profiles\n", .{});
    print("  --update            Update all template files for a profile in current dir\n", .{});
    print("  -h, --help          Show this help\n", .{});
    print("  -v, --version       Show version\n\n", .{});
    print("Examples:\n", .{});
    print("  init-agent my-project\n", .{});
    print("  init-agent my-api --profile python\n", .{});
    print("  init-agent my-api --name \"My Awesome API\" --profile python\n", .{});
    print("  init-agent my-app --profile web-app --author 'Jane Doe'\n", .{});
    print("  init-agent my-cli --profile zig-cli --force\n", .{});
    print("  init-agent my-cli --profile zig-cli --skip-existing\n", .{});
    print("  init-agent my-project --dry-run --verbose\n", .{});
    print("  init-agent my-project --interactive\n\n", .{});
}

fn printVersion() void {
    print("init-agent version {s}\n", .{VERSION});
}

fn printProfiles() void {
    print("Available profiles:\n\n", .{});
    const profiles = &[_]Profile{ PYTHON_PROFILE, WEBAPP_PROFILE, ZIGCLI_PROFILE };
    for (profiles) |profile| {
        print("  {s:12} - {s}\n", .{ profile.name, profile.description });
    }
    print("\n", .{});
}

fn getCurrentDate() []const u8 {
    return "2026-02-17";
}

fn getDefaultAuthor(allocator: std.mem.Allocator) []const u8 {
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{ "git", "config", "user.name" },
    }) catch return allocator.dupe(u8, "Anonymous") catch "Anonymous";

    if (result.term == .Exited and result.term.Exited == 0) {
        const name = std.mem.trim(u8, result.stdout, " \n\r\t");
        if (name.len > 0) {
            return allocator.dupe(u8, name) catch "Anonymous";
        }
    }
    return allocator.dupe(u8, "Anonymous") catch "Anonymous";
}

/// Replace all occurrences of needle with replacement in content
fn replaceAll(allocator: std.mem.Allocator, content: []const u8, needle: []const u8, replacement: []const u8) ![]u8 {
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

    const new_len = content.len - (count * needle.len) + (count * replacement.len);
    var result = try allocator.alloc(u8, new_len);
    errdefer allocator.free(result);

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

const VariableMap = struct {
    project_name: []const u8,
    date: []const u8,
    author: []const u8,
    profile: []const u8,
    output_dir: []const u8,
};

/// Apply all variable substitutions to content
fn substituteVariables(allocator: std.mem.Allocator, content: []const u8, vars: VariableMap) ![]u8 {
    var result = try allocator.dupe(u8, content);
    errdefer allocator.free(result);

    const replacements = .{
        .{ "{{PROJECT_NAME}}", vars.project_name },
        .{ "{{DATE}}", vars.date },
        .{ "{{AUTHOR}}", vars.author },
        .{ "{{PROFILE}}", vars.profile },
        .{ "{{OUTPUT_DIR}}", vars.output_dir },
    };

    inline for (replacements) |replacement| {
        const new_result = try replaceAll(allocator, result, replacement[0], replacement[1]);
        allocator.free(result);
        result = new_result;
    }

    return result;
}

/// Check if content contains any unresolved placeholder patterns ({{VAR}})
fn hasUnresolvedPlaceholders(content: []const u8) bool {
    var i: usize = 0;
    while (i < content.len) {
        if (content[i] == '{' and i + 1 < content.len and content[i + 1] == '{') {
            // Found opening {{
            i += 2;
            // Look for closing }}
            while (i < content.len) {
                if (content[i] == '}' and i + 1 < content.len and content[i + 1] == '}') {
                    // Found a complete placeholder {{...}}
                    return true;
                }
                i += 1;
            }
            // No closing }} found, but we already found {{
            return true;
        }
        i += 1;
    }
    return false;
}

/// Extract and collect unresolved placeholder names from content
fn collectUnresolvedPlaceholders(allocator: std.mem.Allocator, content: []const u8) ![][]const u8 {
    var placeholders: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (placeholders.items) |p| {
            allocator.free(p);
        }
        placeholders.deinit(allocator);
    }

    var i: usize = 0;
    while (i < content.len) {
        if (content[i] == '{' and i + 1 < content.len and content[i + 1] == '{') {
            const start = i;
            i += 2;
            var end: usize = i;
            while (i < content.len) {
                if (content[i] == '}' and i + 1 < content.len and content[i + 1] == '}') {
                    const placeholder = content[start..i + 2];
                    const duped = try allocator.dupe(u8, placeholder);
                    try placeholders.append(allocator, duped);
                    i += 2;
                    end = i;
                    break;
                }
                i += 1;
            }
            if (end == start + 2) {
                // No closing found, but we already found {{
                i = start + 2;
            }
        } else {
            i += 1;
        }
    }

    return placeholders.toOwnedSlice(allocator);
}

// =============================================================================
// File Operations
// =============================================================================

fn directoryExists(path: []const u8) bool {
    fs.cwd().access(path, .{}) catch return false;
    return true;
}

fn fileExists(dir: fs.Dir, relative_path: []const u8) bool {
    dir.access(relative_path, .{}) catch return false;
    return true;
}

fn removeDirectoryRecursive(path: []const u8) !void {
    try fs.cwd().deleteTree(path);
}

fn readFileContent(allocator: std.mem.Allocator, dir: fs.Dir, relative_path: []const u8) !?[]u8 {
    const file = dir.openFile(relative_path, .{}) catch |err| {
        if (err == error.FileNotFound) return null;
        return err;
    };
    defer file.close();

    const stat = try file.stat();
    const content = try allocator.alloc(u8, stat.size);
    errdefer allocator.free(content);

    const bytes_read = try file.readAll(content);
    if (bytes_read != stat.size) {
        return error.Unexpected;
    }

    return content;
}

/// Compare two byte slices for equality
fn contentEqual(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    return std.mem.eql(u8, a, b);
}

/// Print a simple diff between two contents
fn printDiff(allocator: std.mem.Allocator, old_content: []const u8, new_content: []const u8, file_path: []const u8) void {
    _ = allocator;
    print("\n--- {s} (existing)\n", .{file_path});
    print("+++ {s} (new)\n\n", .{file_path});

    // Simple line-by-line diff
    var old_lines = std.mem.splitScalar(u8, old_content, '\n');
    var new_lines = std.mem.splitScalar(u8, new_content, '\n');

    var line_num: usize = 1;
    var has_diff = false;

    while (old_lines.next()) |old_line| {
        const new_line = new_lines.next();
        if (new_line == null) {
            print("-{d}: {s}\n", .{ line_num, old_line });
            has_diff = true;
        } else if (!std.mem.eql(u8, old_line, new_line.?)) {
            print("-{d}: {s}\n", .{ line_num, old_line });
            print("+{d}: {s}\n", .{ line_num, new_line.? });
            has_diff = true;
        }
        line_num += 1;
    }

    while (new_lines.next()) |new_line| {
        print("+{d}: {s}\n", .{ line_num, new_line });
        has_diff = true;
        line_num += 1;
    }

    if (!has_diff) {
        print("(Files are identical)\n", .{});
    }
    print("\n", .{});
}

fn writeFile(dir: fs.Dir, relative_path: []const u8, content: []const u8) !void {
    if (std.mem.indexOf(u8, relative_path, "/")) |last_slash| {
        const parent_dir = relative_path[0..last_slash];
        dir.makePath(parent_dir) catch |err| {
            if (err != error.PathAlreadyExists) return err;
        };
    }

    const file = try dir.createFile(relative_path, .{});
    defer file.close();
    try file.writeAll(content);
}

/// Prompt user for action when file exists and differs
fn promptFileAction(file_path: []const u8) FileAction {
    while (true) {
        print("File exists and differs: {s}\n", .{file_path});
        print("[o]verwrite, [s]kip, [O]verwrite all, [S]kip all, [d]iff, [q]uit? ", .{});

        var buf: [10]u8 = undefined;
        const stdin = std.fs.File{ .handle = std.posix.STDIN_FILENO };
        const bytes_read = stdin.read(&buf) catch {
            print("Error reading input, defaulting to skip\n", .{});
            return .skip;
        };

        if (bytes_read == 0) continue;

        const input = std.mem.trim(u8, buf[0..bytes_read], " \n\r\t");
        if (input.len == 0) continue;

        switch (input[0]) {
            'o', 'O' => {
                if (input[0] == 'O') {
                    g_overwrite_all = true;
                    return .overwrite_all;
                }
                return .overwrite;
            },
            's', 'S' => {
                if (input[0] == 'S') {
                    g_skip_all = true;
                    return .skip_all;
                }
                return .skip;
            },
            'd', 'D' => return .show_diff,
            'q', 'Q' => return .quit,
            else => print("Invalid option. Please try again.\n\n", .{}),
        }
    }
}

/// Determine what action to take for a file
fn shouldWriteFile(
    allocator: std.mem.Allocator,
    project_dir: fs.Dir,
    file_path: []const u8,
    new_content: []const u8,
    config: Config,
) ScaffoldError!FileAction {
    // If force flag is set, always overwrite
    if (config.force) {
        return .overwrite;
    }

    // If skip-existing flag is set, skip existing files
    if (config.skip_existing) {
        if (fileExists(project_dir, file_path)) {
            // Check if content is identical
            const existing_content = readFileContent(allocator, project_dir, file_path) catch |err| {
                print("Warning: Could not read existing file '{s}': {s}\n", .{ file_path, @errorName(err) });
                return .skip;
            };
            if (existing_content) |content| {
                defer allocator.free(content);
                if (contentEqual(content, new_content)) {
                    print("⏭️  Skipped {s} (identical)\n", .{file_path});
                } else {
                    print("⏭️  Skipped {s} (existing)\n", .{file_path});
                }
            } else {
                print("⏭️  Skipped {s} (existing)\n", .{file_path});
            }
            return .skip;
        }
        return .overwrite;
    }

    // Check if file exists
    if (!fileExists(project_dir, file_path)) {
        return .overwrite;
    }

    // Read existing content
    const existing_content = readFileContent(allocator, project_dir, file_path) catch |err| {
        print("Warning: Could not read existing file '{s}': {s}\n", .{ file_path, @errorName(err) });
        return .overwrite; // Write anyway if we can't read
    } orelse return .overwrite; // File disappeared, write it

    defer allocator.free(existing_content);

    // Check if content is identical
    if (contentEqual(existing_content, new_content)) {
        print("⏭️  Skipped {s} (identical)\n", .{file_path});
        return .skip;
    }

    // Content differs - prompt user
    return promptFileAction(file_path);
}

// =============================================================================
// Scaffold Logic
// =============================================================================

fn createScaffold(config: Config) ScaffoldError!void {
    const allocator = config.allocator;

    const profile = getProfile(config.profile_name) orelse return ScaffoldError.InvalidProfile;
    config.logVerbose("Loading profile: {s}\n", .{profile.name});

    // Reset global batch state
    g_overwrite_all = false;
    g_skip_all = false;

    const exists = directoryExists(config.output_dir);

    // If force flag is set and directory exists, remove it entirely
    if (exists and config.force) {
        if (config.dry_run) {
            print("[DRY RUN] Would remove existing directory: {s}\n", .{config.output_dir});
        } else {
            removeDirectoryRecursive(config.output_dir) catch |err| {
                print("Error removing existing directory: {s}\n", .{@errorName(err)});
                return ScaffoldError.IoError;
            };
            config.logVerbose("Removed existing directory: {s}\n", .{config.output_dir});
        }
    }

    // Prepare variables for substitution
    const vars = VariableMap{
        .project_name = config.display_name,
        .date = getCurrentDate(),
        .author = config.author,
        .profile = profile.display_name,
        .output_dir = config.output_dir,
    };

    // Handle dry-run mode
    if (config.dry_run) {
        print("[DRY RUN] Would create directory: {s}\n", .{config.output_dir});
        for (profile.directories) |dir_template| {
            const dir_path = try substituteVariables(allocator, dir_template, vars);
            defer allocator.free(dir_path);
            print("[DRY RUN] Would create directory: {s}/{s}\n", .{ config.output_dir, dir_path });
        }
        // In dry-run, skip actual directory operations and go straight to file preview
    } else {
        // Create output directory if it doesn't exist
        if (!exists or config.force) {
            fs.cwd().makeDir(config.output_dir) catch |err| {
                print("Error creating directory: {s}\n", .{@errorName(err)});
                return ScaffoldError.IoError;
            };
            config.logVerbose("Created directory: {s}\n", .{config.output_dir});
        }

        // Open directory for file operations
        var project_dir = fs.cwd().openDir(config.output_dir, .{}) catch |err| {
            print("Error opening directory: {s}\n", .{@errorName(err)});
            return ScaffoldError.IoError;
        };
        defer project_dir.close();

        // Create subdirectories
        for (profile.directories) |dir_template| {
            const dir_path = try substituteVariables(allocator, dir_template, vars);
            defer allocator.free(dir_path);

            project_dir.makePath(dir_path) catch |err| {
                if (err != error.PathAlreadyExists) {
                    print("Error creating directory '{s}': {s}\n", .{ dir_path, @errorName(err) });
                    return ScaffoldError.IoError;
                }
            };
            config.logVerbose("Created directory: {s}\n", .{dir_path});
        }

        // Create files with smart overwrite handling
        for (profile.files) |template_file| {
            const target_path = try substituteVariables(allocator, template_file.target_path, vars);
            defer allocator.free(target_path);

            const content = try substituteVariables(allocator, template_file.content, vars);
            errdefer allocator.free(content);

            // Check for unresolved placeholders
            if (hasUnresolvedPlaceholders(content)) {
                const placeholders = collectUnresolvedPlaceholders(allocator, content) catch |err| blk: {
                    print("Warning: Could not collect unresolved placeholders: {s}\n", .{@errorName(err)});
                    break :blk null;
                };
                defer if (placeholders) |phs| {
                    for (phs) |p| {
                        allocator.free(p);
                    }
                    allocator.free(phs);
                };

                if (placeholders) |phs| {
                    if (phs.len > 0) {
                        print("Warning: Unresolved placeholders in {s}:", .{target_path});
                        for (phs) |p| {
                            print(" {s}", .{p});
                        }
                        print("\n", .{});
                    }
                }
            }

            config.logVerbose("Processing file: {s} ({d} bytes after substitution)\n", .{ target_path, content.len });

            // Check if we should write this file
            var action: FileAction = undefined;

            if (g_overwrite_all) {
                action = .overwrite;
            } else if (g_skip_all) {
                action = .skip;
            } else {
                action = try shouldWriteFile(allocator, project_dir, target_path, content, config);
            }

            switch (action) {
                .overwrite, .overwrite_all => {
                    writeFile(project_dir, target_path, content) catch |err| {
                        print("Error writing file '{s}': {s}\n", .{ target_path, @errorName(err) });
                        allocator.free(content);
                        return ScaffoldError.IoError;
                    };
                    config.logVerbose("Wrote file: {s} ({d} bytes)\n", .{ target_path, content.len });
                    print("✅ Created {s}\n", .{target_path});
                },
                .skip, .skip_all => {
                    // File skipped
                },
                .show_diff => {
                    const existing = readFileContent(allocator, project_dir, target_path) catch |err| {
                        print("Error reading file for diff '{s}': {s}\n", .{ target_path, @errorName(err) });
                        allocator.free(content);
                        continue;
                    } orelse {
                        print("File no longer exists: {s}\n", .{target_path});
                        allocator.free(content);
                        continue;
                    };
                    defer allocator.free(existing);

                    printDiff(allocator, existing, content, target_path);

                    const new_action = promptFileAction(target_path);
                    switch (new_action) {
                        .overwrite, .overwrite_all => {
                            if (new_action == .overwrite_all) {
                                g_overwrite_all = true;
                            }
                            writeFile(project_dir, target_path, content) catch |err| {
                                print("Error writing file '{s}': {s}\n", .{ target_path, @errorName(err) });
                                allocator.free(content);
                                return ScaffoldError.IoError;
                            };
                            print("✅ Created {s}\n", .{target_path});
                        },
                        .skip, .skip_all => {
                            if (new_action == .skip_all) {
                                g_skip_all = true;
                            }
                        },
                        .quit => {
                            allocator.free(content);
                            return ScaffoldError.UserAborted;
                        },
                        else => {},
                    }
                },
                .quit => {
                    allocator.free(content);
                    return ScaffoldError.UserAborted;
                },
            }

            allocator.free(content);
        }

        // Initialize git if requested
        if (config.init_git) {
            const git_result = std.process.Child.run(.{
                .allocator = allocator,
                .argv = &.{ "git", "init", config.output_dir },
            }) catch |err| blk: {
                print("Warning: Could not initialize git repository: {s}\n", .{@errorName(err)});
                break :blk null;
            };
            if (git_result) |result| {
                allocator.free(result.stdout);
                allocator.free(result.stderr);
                config.logVerbose("Initialized git repository\n", .{});
            }
        }

        return; // Exit early - we've done all the work
    }

    // Dry-run file preview (only reached in dry-run mode)
    for (profile.files) |template_file| {
        const target_path = try substituteVariables(allocator, template_file.target_path, vars);
        defer allocator.free(target_path);

        const content = try substituteVariables(allocator, template_file.content, vars);
        defer allocator.free(content);

        // Check for unresolved placeholders
        if (hasUnresolvedPlaceholders(content)) {
            const placeholders = collectUnresolvedPlaceholders(allocator, content) catch null;
            defer if (placeholders) |phs| {
                for (phs) |p| {
                    allocator.free(p);
                }
                allocator.free(phs);
            };

            if (placeholders) |phs| {
                if (phs.len > 0) {
                    print("Warning: Unresolved placeholders in {s}:", .{target_path});
                    for (phs) |p| {
                        print(" {s}", .{p});
                    }
                    print("\n", .{});
                }
            }
        }

        config.logVerbose("Processing file: {s} ({d} bytes after substitution)\n", .{ target_path, content.len });
        print("[DRY RUN] Would create file: {s}/{s} ({d} bytes)\n", .{ config.output_dir, target_path, content.len });
    }

    if (config.init_git) {
        print("[DRY RUN] Would initialize git repository in: {s}\n", .{config.output_dir});
    }
}

// =============================================================================
// Update Contract Files
// =============================================================================

/// Detect project name from existing context.md or fall back to directory name
fn detectProjectName(allocator: std.mem.Allocator) ![]const u8 {
    // Try to read project name from context.md header
    const cwd = fs.cwd();
    const maybe_content = readFileContent(allocator, cwd, "context.md") catch null;
    if (maybe_content) |content| {
        defer allocator.free(content);
        // Look for "# <name> Session Context" pattern
        if (std.mem.indexOf(u8, content, "# ")) |start| {
            const after_hash = content[start + 2 ..];
            if (std.mem.indexOf(u8, after_hash, " Session Context")) |end| {
                const name = std.mem.trim(u8, after_hash[0..end], " \n\r\t");
                if (name.len > 0) {
                    return try allocator.dupe(u8, name);
                }
            }
        }
    }

    // Fall back to current directory name
    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const cwd_path = try std.process.getCwd(&path_buf);
    const dir_name = std.fs.path.basename(cwd_path);
    return try allocator.dupe(u8, dir_name);
}

/// Detect profile from existing context.md or fall back to "python"
fn detectProfile(allocator: std.mem.Allocator) []const u8 {
    const cwd = fs.cwd();
    const maybe_content = readFileContent(allocator, cwd, "context.md") catch null;
    if (maybe_content) |content| {
        defer allocator.free(content);
        // Look for "**Profile**: <name>" pattern
        if (std.mem.indexOf(u8, content, "**Profile**: ")) |start| {
            const after = content[start + 13 ..];
            if (std.mem.indexOf(u8, after, "\n")) |end| {
                const profile = std.mem.trim(u8, after[0..end], " \r\t");
                if (profile.len > 0) {
                    return allocator.dupe(u8, profile) catch "Python Package";
                }
            }
        }
    }
    return allocator.dupe(u8, "Python Package") catch "Python Package";
}

fn updateProjectFiles(allocator: std.mem.Allocator, profile_name_arg: []const u8) !void {
    const project_name = try detectProjectName(allocator);
    defer allocator.free(project_name);

    // Determine profile: from arg, from context.md detection, or default
    var profile_key: []const u8 = "python"; // default
    if (profile_name_arg.len > 0) {
        profile_key = profile_name_arg;
    } else {
        // Try to detect from context.md profile field
        const detected = detectProfile(allocator);
        defer allocator.free(detected);
        // Map display names back to profile keys
        if (mem.eql(u8, detected, "Python Package")) {
            profile_key = "python";
        } else if (mem.eql(u8, detected, "Web Application (React + Vite)")) {
            profile_key = "web-app";
        } else if (mem.eql(u8, detected, "Zig CLI Tool")) {
            profile_key = "zig-cli";
        }
    }

    const profile = getProfile(profile_key) orelse {
        print("Error: Unknown profile: {s}\n", .{profile_key});
        print("Use --profile with one of: python, web-app, zig-cli\n", .{});
        return;
    };

    const author = getDefaultAuthor(allocator);
    defer allocator.free(author);

    const vars = VariableMap{
        .project_name = project_name,
        .date = getCurrentDate(),
        .author = author,
        .profile = profile.display_name,
        .output_dir = ".",
    };

    cprint(Color.bold, "\n🔄 Updating project files for: {s}\n", .{project_name});
    cprint(Color.cyan, "   Profile:  {s}\n", .{profile.display_name});
    cprint(Color.cyan, "   Version:  {s}\n\n", .{VERSION});

    const cwd = fs.cwd();
    var updated: usize = 0;
    var skipped: usize = 0;

    for (profile.files) |template_file| {
        const target_path = try substituteVariables(allocator, template_file.target_path, vars);
        defer allocator.free(target_path);

        const content = try substituteVariables(allocator, template_file.content, vars);
        defer allocator.free(content);

        // Check if file exists and compare
        const maybe_existing = readFileContent(allocator, cwd, target_path) catch null;
        if (maybe_existing) |existing| {
            defer allocator.free(existing);
            if (contentEqual(existing, content)) {
                cprint(Color.cyan, "⏭️  {s} (already up to date)\n", .{target_path});
                skipped += 1;
                continue;
            }
        }

        // Write the file (create parent dirs if needed)
        writeFile(cwd, target_path, content) catch |err| {
            print("Error writing '{s}': {s}\n", .{ target_path, @errorName(err) });
            continue;
        };
        cprint(Color.green, "✅ Updated {s}\n", .{target_path});
        updated += 1;
    }

    print("\n", .{});
    if (updated > 0) {
        cprint(Color.green, "✅ Updated {d} file(s)", .{updated});
        if (skipped > 0) {
            cprint(Color.cyan, ", {d} already current", .{skipped});
        }
        print("\n", .{});
    } else {
        cprint(Color.green, "✅ All files are already up to date\n", .{});
    }
}

// =============================================================================
// Main Entry Point
// =============================================================================

pub fn main() !void {
    initColorSupport();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        printUsage();
        return;
    }

    const first_arg = args[1];

    if (mem.eql(u8, first_arg, "-h") or mem.eql(u8, first_arg, "--help")) {
        printUsage();
        return;
    }

    if (mem.eql(u8, first_arg, "-v") or mem.eql(u8, first_arg, "--version")) {
        printVersion();
        return;
    }

    if (mem.eql(u8, first_arg, "--list")) {
        printProfiles();
        return;
    }

    if (mem.eql(u8, first_arg, "--update")) {
        // Parse optional --profile flag from remaining args
        var update_profile_name: []const u8 = "";
        var j: usize = 2;
        while (j < args.len) : (j += 1) {
            if (mem.eql(u8, args[j], "--profile") and j + 1 < args.len) {
                j += 1;
                update_profile_name = args[j];
            }
        }
        updateProjectFiles(allocator, update_profile_name) catch |err| {
            print("Error updating files: {s}\n", .{@errorName(err)});
        };
        return;
    }

    const project_name = first_arg;
    if (project_name.len == 0 or mem.eql(u8, project_name, "--")) {
        print("Error: Invalid project name\n", .{});
        return;
    }

    for (project_name) |c| {
        if (!std.ascii.isAlphanumeric(c) and c != '-' and c != '_' and c != '.') {
            print("Error: Project name contains invalid characters. Use only alphanumeric, '-', '_', '.'\n", .{});
            return;
        }
    }

    const default_author = getDefaultAuthor(allocator);
    defer allocator.free(default_author);

    var config = Config{
        .project_name = try allocator.dupe(u8, project_name),
        .display_name = try allocator.dupe(u8, project_name),
        .profile_name = "python",
        .output_dir = try std.fs.path.join(allocator, &.{ ".", project_name }),
        .force = false,
        .skip_existing = false,
        .init_git = true,
        .author = try allocator.dupe(u8, default_author),
        .dry_run = false,
        .verbose = false,
        .interactive = false,
        .allocator = allocator,
    };
    defer config.deinit();

    var i: usize = 2;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (mem.eql(u8, arg, "--name")) {
            if (i + 1 >= args.len) {
                print("Error: --name requires a value\n", .{});
                return;
            }
            i += 1;
            allocator.free(config.display_name);
            config.display_name = try allocator.dupe(u8, args[i]);
        } else if (mem.eql(u8, arg, "--profile")) {
            if (i + 1 >= args.len) {
                print("Error: --profile requires a value\n", .{});
                return;
            }
            i += 1;
            config.profile_name = args[i];
        } else if (mem.eql(u8, arg, "--dir")) {
            if (i + 1 >= args.len) {
                print("Error: --dir requires a value\n", .{});
                return;
            }
            i += 1;
            allocator.free(config.output_dir);
            config.output_dir = try allocator.dupe(u8, args[i]);
        } else if (mem.eql(u8, arg, "--author")) {
            if (i + 1 >= args.len) {
                print("Error: --author requires a value\n", .{});
                return;
            }
            i += 1;
            allocator.free(config.author);
            config.author = try allocator.dupe(u8, args[i]);
        } else if (mem.eql(u8, arg, "--force")) {
            config.force = true;
        } else if (mem.eql(u8, arg, "--skip-existing")) {
            config.skip_existing = true;
        } else if (mem.eql(u8, arg, "--no-git")) {
            config.init_git = false;
        } else if (mem.eql(u8, arg, "--dry-run")) {
            config.dry_run = true;
        } else if (mem.eql(u8, arg, "--verbose")) {
            config.verbose = true;
        } else if (mem.eql(u8, arg, "--interactive")) {
            config.interactive = true;
        } else {
            print("Error: Unknown option: {s}\n", .{arg});
            return;
        }
    }

    // Validate that --force and --skip-existing are not used together
    if (config.force and config.skip_existing) {
        print("Error: --force and --skip-existing cannot be used together\n", .{});
        return;
    }

    // Interactive mode: prompt for missing values
    if (config.interactive) {
        const stdin = std.fs.File{ .handle = std.posix.STDIN_FILENO };

        // Prompt for display name
        if (mem.eql(u8, config.display_name, config.project_name)) {
            print("Project display name [{s}]: ", .{config.display_name});
            var buf: [256]u8 = undefined;
            const bytes_read = stdin.read(&buf) catch 0;
            if (bytes_read > 0) {
                const input = std.mem.trim(u8, buf[0..bytes_read], " \n\r\t");
                if (input.len > 0) {
                    allocator.free(config.display_name);
                    config.display_name = try allocator.dupe(u8, input);
                }
            }
        }

        // Prompt for author
        if (mem.eql(u8, config.author, "Anonymous")) {
            print("Author name [Anonymous]: ", .{});
            var buf: [256]u8 = undefined;
            const bytes_read = stdin.read(&buf) catch 0;
            if (bytes_read > 0) {
                const input = std.mem.trim(u8, buf[0..bytes_read], " \n\r\t");
                if (input.len > 0) {
                    allocator.free(config.author);
                    config.author = try allocator.dupe(u8, input);
                }
            }
        }

        // Prompt for profile
        print("Profile (python/web-app/zig-cli) [{s}]: ", .{config.profile_name});
        var buf: [256]u8 = undefined;
        while (true) {
            const bytes_read = stdin.read(&buf) catch 0;
            if (bytes_read == 0) break;
            const input = std.mem.trim(u8, buf[0..bytes_read], " \n\r\t");
            if (input.len == 0) break; // Use default
            if (getProfile(input) != null) {
                config.profile_name = input;
                break;
            }
            print("Invalid profile. Choose from: python, web-app, zig-cli [{s}]: ", .{config.profile_name});
        }
    }

    if (getProfile(config.profile_name) == null) {
        print("Error: Unknown profile: {s}\n", .{config.profile_name});
        print("Run with --list to see available profiles\n", .{});
        return;
    }

    const profile = getProfile(config.profile_name).?;
    if (config.dry_run) {
        cprint(Color.yellow, "\n[DRY RUN] Would create project: {s}\n", .{project_name});
    } else {
        cprint(Color.bold, "\n🚀 Creating project: {s}\n", .{project_name});
    }
    cprint(Color.cyan, "   Display:  {s}\n", .{config.display_name});
    cprint(Color.cyan, "   Profile:  {s}\n", .{profile.display_name});
    cprint(Color.cyan, "   Author:   {s}\n", .{config.author});
    cprint(Color.cyan, "   Location: {s}\n", .{config.output_dir});
    if (config.dry_run) {
        cprint(Color.yellow, "   Mode:     dry-run (preview only)\n", .{});
    } else if (config.force) {
        cprint(Color.red, "   Mode:     force (overwrite all)\n", .{});
    } else if (config.skip_existing) {
        cprint(Color.yellow, "   Mode:     skip existing\n", .{});
    } else {
        cprint(Color.green, "   Mode:     interactive\n", .{});
    }
    if (config.verbose) {
        cprint(Color.cyan, "   Verbose:  enabled\n", .{});
    }
    print("\n", .{});

    createScaffold(config) catch |err| {
        switch (err) {
            ScaffoldError.ProjectExists => {
                print("Error: Project directory already exists: {s}\n", .{config.output_dir});
                print("       Use --force to overwrite or --skip-existing to skip existing files\n", .{});
            },
            ScaffoldError.InvalidProfile => {
                print("Error: Invalid profile: {s}\n", .{config.profile_name});
            },
            ScaffoldError.IoError => {
                print("Error: Could not create project files\n", .{});
            },
            ScaffoldError.UserAborted => {
                print("\n⚠️  Aborted by user\n", .{});
                return;
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

    if (config.dry_run) {
        cprint(Color.yellow, "\n[DRY RUN] Preview complete. No files were created.\n", .{});
    } else {
        cprint(Color.green, "\n✅ Created {s}\n", .{project_name});
        cprint(Color.green, "✅ Generated files from {s} profile\n", .{profile.name});
        if (config.init_git) {
            cprint(Color.green, "✅ Initialized git repository\n", .{});
        }
    }

    cprint(Color.cyan, "\nNext steps:\n", .{});
    print("  cd {s}\n", .{config.output_dir});
    print("  [Your AI agent reads AGENTS.md and begins]\n", .{});
}

// =============================================================================
// Unit Tests
// =============================================================================

test "replaceAll replaces all occurrences" {
    const allocator = std.testing.allocator;

    // Test basic replacement
    const result1 = try replaceAll(allocator, "Hello World", "World", "Zig");
    defer allocator.free(result1);
    try std.testing.expectEqualStrings("Hello Zig", result1);

    // Test multiple occurrences
    const result2 = try replaceAll(allocator, "foo bar foo baz foo", "foo", "XXX");
    defer allocator.free(result2);
    try std.testing.expectEqualStrings("XXX bar XXX baz XXX", result2);

    // Test no matches (returns copy)
    const result3 = try replaceAll(allocator, "Hello World", "xyz", "abc");
    defer allocator.free(result3);
    try std.testing.expectEqualStrings("Hello World", result3);
    try std.testing.expect(result3.ptr != "Hello World".ptr);

    // Test empty replacement (deletes needle)
    const result4 = try replaceAll(allocator, "Hello World World", " World", "");
    defer allocator.free(result4);
    try std.testing.expectEqualStrings("Hello", result4);

    // Test overlapping potential
    const result5 = try replaceAll(allocator, "aaa", "aa", "b");
    defer allocator.free(result5);
    try std.testing.expectEqualStrings("ba", result5);
}

test "substituteVariables replaces all template variables" {
    const allocator = std.testing.allocator;

    // Test with all variables
    const content1 = "Project: {{PROJECT_NAME}} by {{AUTHOR}} on {{DATE}} using {{PROFILE}}";
    const vars1 = VariableMap{
        .project_name = "TestProject",
        .date = "2026-02-17",
        .author = "Test Author",
        .profile = "python",
        .output_dir = "/test/output",
    };
    const result1 = try substituteVariables(allocator, content1, vars1);
    defer allocator.free(result1);
    try std.testing.expectEqualStrings("Project: TestProject by Test Author on 2026-02-17 using python", result1);

    // Test with partial variables
    const content2 = "Project: {{PROJECT_NAME}}";
    const vars2 = VariableMap{
        .project_name = "MyProject",
        .date = "2026-02-17",
        .author = "Author Name",
        .profile = "zig-cli",
        .output_dir = "/my/project",
    };
    const result2 = try substituteVariables(allocator, content2, vars2);
    defer allocator.free(result2);
    try std.testing.expectEqualStrings("Project: MyProject", result2);

    // Test with repeated variables
    const content3 = "{{PROJECT_NAME}} uses {{PROJECT_NAME}} as its name";
    const vars3 = VariableMap{
        .project_name = "RepeatMe",
        .date = "2026-02-17",
        .author = "Author",
        .profile = "web-app",
        .output_dir = "/repeat",
    };
    const result3 = try substituteVariables(allocator, content3, vars3);
    defer allocator.free(result3);
    try std.testing.expectEqualStrings("RepeatMe uses RepeatMe as its name", result3);

    // Test empty variable values
    const content4 = "Project: '{{PROJECT_NAME}}' Author: '{{AUTHOR}}'";
    const vars4 = VariableMap{
        .project_name = "",
        .date = "2026-02-17",
        .author = "",
        .profile = "python",
        .output_dir = "",
    };
    const result4 = try substituteVariables(allocator, content4, vars4);
    defer allocator.free(result4);
    try std.testing.expectEqualStrings("Project: '' Author: ''", result4);
}

test "hasUnresolvedPlaceholders detects remaining placeholders" {
    // The hasUnresolvedPlaceholders function returns true for ANY {{...}} pattern
    // (It's a simple check that just looks for double braces)

    // Test with any placeholder - returns true
    try std.testing.expect(hasUnresolvedPlaceholders("Project: {{PROJECT_NAME}} and {{UNKNOWN_VAR}}"));

    // Test with single placeholder - returns true
    try std.testing.expect(hasUnresolvedPlaceholders("Value: {{SOME_OTHER_VAR}}"));

    // Test with known placeholders - still returns true (function doesn't distinguish)
    try std.testing.expect(hasUnresolvedPlaceholders("Project: {{PROJECT_NAME}} by {{AUTHOR}} on {{DATE}} using {{PROFILE}}"));

    // Test with empty string - returns false
    try std.testing.expect(!hasUnresolvedPlaceholders(""));

    // Test with no placeholders at all - returns false
    try std.testing.expect(!hasUnresolvedPlaceholders("Plain text without any braces"));

    // Test with partial/unclosed placeholder - returns true (found {{)
    try std.testing.expect(hasUnresolvedPlaceholders("Value: {{UNCLOSED"));

    // Test with known placeholders only - returns true
    try std.testing.expect(hasUnresolvedPlaceholders("{{PROJECT_NAME}} - {{AUTHOR}}"));

    // Test with single braces - returns false
    try std.testing.expect(!hasUnresolvedPlaceholders("Value: {PROJECT_NAME}"));
}

test "contentEqual compares content correctly" {
    try std.testing.expect(contentEqual("hello", "hello"));
    try std.testing.expect(!contentEqual("hello", "world"));
    try std.testing.expect(!contentEqual("hello", "hello world"));
    try std.testing.expect(!contentEqual("hello world", "hello"));
    try std.testing.expect(contentEqual("", ""));
    try std.testing.expect(!contentEqual("a", ""));
    try std.testing.expect(!contentEqual("", "a"));
}
