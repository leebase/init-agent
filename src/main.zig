const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const print = std.debug.print;

const VERSION = "0.3.0";

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
        .{ .target_path = "README.md", .content = PYTHON_README_MD },
        .{ .target_path = "pyproject.toml", .content = PYTHON_PYPROJECT_TOML },
        .{ .target_path = "src/{{PROJECT_NAME}}/__init__.py", .content = PYTHON_SRC_INIT_PY },
        .{ .target_path = "src/{{PROJECT_NAME}}/main.py", .content = PYTHON_SRC_MAIN_PY },
    },
    .directories = &[_][]const u8{
        "src/{{PROJECT_NAME}}",
        "tests",
    },
};

const WEBAPP_PROFILE = Profile{
    .name = "web-app",
    .display_name = "Web Application (React + Vite)",
    .description = "Modern web app with React, TypeScript, and Vite",
    .files = &[_]TemplateFile{
        .{ .target_path = "AGENTS.md", .content = COMMON_AGENT_MD },
        .{ .target_path = "WHERE_AM_I.md", .content = COMMON_WHERE_AM_I_MD },
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
    },
};

const ZIGCLI_PROFILE = Profile{
    .name = "zig-cli",
    .display_name = "Zig CLI Tool",
    .description = "Command-line tool built with Zig",
    .files = &[_]TemplateFile{
        .{ .target_path = "AGENTS.md", .content = COMMON_AGENT_MD },
        .{ .target_path = "WHERE_AM_I.md", .content = COMMON_WHERE_AM_I_MD },
        .{ .target_path = "README.md", .content = ZIGCLI_README_MD },
        .{ .target_path = "build.zig", .content = ZIGCLI_BUILD_ZIG },
        .{ .target_path = "src/main.zig", .content = ZIGCLI_SRC_MAIN_ZIG },
    },
    .directories = &[_][]const u8{
        "src",
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
    init_git: bool,
    author: []const u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Config) void {
        self.allocator.free(self.project_name);
        self.allocator.free(self.display_name);
        self.allocator.free(self.output_dir);
        self.allocator.free(self.author);
    }
};

const ScaffoldError = error{
    ProjectExists,
    InvalidProfile,
    InvalidProjectName,
    IoError,
    OutOfMemory,
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
    print("  --force             Overwrite existing directory\n", .{});
    print("  --no-git            Skip git initialization\n", .{});
    print("  --list              List available profiles\n", .{});
    print("  -h, --help          Show this help\n", .{});
    print("  -v, --version       Show version\n\n", .{});
    print("Examples:\n", .{});
    print("  init-agent my-project\n", .{});
    print("  init-agent my-api --profile python\n", .{});
    print("  init-agent my-api --name \"My Awesome API\" --profile python\n", .{});
    print("  init-agent my-app --profile web-app --author 'Jane Doe'\n", .{});
    print("  init-agent my-cli --profile zig-cli --force\n\n", .{});
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

fn removeDirectoryRecursive(path: []const u8) !void {
    try fs.cwd().deleteTree(path);
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

// =============================================================================
// Scaffold Logic
// =============================================================================

fn createScaffold(config: Config) ScaffoldError!void {
    const allocator = config.allocator;

    const profile = getProfile(config.profile_name) orelse return ScaffoldError.InvalidProfile;

    const exists = directoryExists(config.output_dir);
    if (exists and !config.force) {
        return ScaffoldError.ProjectExists;
    }

    if (exists and config.force) {
        removeDirectoryRecursive(config.output_dir) catch |err| {
            print("Error removing existing directory: {s}\n", .{@errorName(err)});
            return ScaffoldError.IoError;
        };
    }

    fs.cwd().makeDir(config.output_dir) catch |err| {
        print("Error creating directory: {s}\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };

    var project_dir = fs.cwd().openDir(config.output_dir, .{}) catch |err| {
        print("Error opening directory: {s}\n", .{@errorName(err)});
        return ScaffoldError.IoError;
    };
    defer project_dir.close();

    const vars = VariableMap{
        .project_name = config.display_name,
        .date = getCurrentDate(),
        .author = config.author,
        .profile = profile.display_name,
    };

    for (profile.directories) |dir_template| {
        const dir_path = try substituteVariables(allocator, dir_template, vars);
        defer allocator.free(dir_path);

        project_dir.makePath(dir_path) catch |err| {
            print("Error creating directory '{s}': {s}\n", .{ dir_path, @errorName(err) });
            return ScaffoldError.IoError;
        };
    }

    for (profile.files) |template_file| {
        const target_path = try substituteVariables(allocator, template_file.target_path, vars);
        defer allocator.free(target_path);

        const content = try substituteVariables(allocator, template_file.content, vars);
        defer allocator.free(content);

        // Check for unresolved placeholders
        if (hasUnresolvedPlaceholders(content)) {
            const placeholders = collectUnresolvedPlaceholders(allocator, content) catch |err| {
                print("Warning: Could not collect unresolved placeholders: {s}\n", .{@errorName(err)});
                // Continue with file creation even if we can't list them
                writeFile(project_dir, target_path, content) catch |write_err| {
                    print("Error writing file '{s}': {s}\n", .{ target_path, @errorName(write_err) });
                    return ScaffoldError.IoError;
                };
                continue;
            };
            defer {
                for (placeholders) |p| {
                    allocator.free(p);
                }
                allocator.free(placeholders);
            }

            if (placeholders.len > 0) {
                print("Warning: Unresolved placeholders in {s}:", .{target_path});
                for (placeholders) |p| {
                    print(" {s}", .{p});
                }
                print("\n", .{});
            }
        }

        writeFile(project_dir, target_path, content) catch |err| {
            print("Error writing file '{s}': {s}\n", .{ target_path, @errorName(err) });
            return ScaffoldError.IoError;
        };
    }

    if (config.init_git) {
        const git_result = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ "git", "init", config.output_dir },
        }) catch |err| {
            print("Warning: Could not initialize git repository: {s}\n", .{@errorName(err)});
            return;
        };
        allocator.free(git_result.stdout);
        allocator.free(git_result.stderr);
    }
}

// =============================================================================
// Main Entry Point
// =============================================================================

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
        .init_git = true,
        .author = try allocator.dupe(u8, default_author),
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
        } else if (mem.eql(u8, arg, "--no-git")) {
            config.init_git = false;
        } else {
            print("Error: Unknown option: {s}\n", .{arg});
            return;
        }
    }

    if (getProfile(config.profile_name) == null) {
        print("Error: Unknown profile: {s}\n", .{config.profile_name});
        print("Run with --list to see available profiles\n", .{});
        return;
    }

    const profile = getProfile(config.profile_name).?;
    print("\n🚀 Creating project: {s}\n", .{project_name});
    print("   Display:  {s}\n", .{config.display_name});
    print("   Profile:  {s}\n", .{profile.display_name});
    print("   Author:   {s}\n", .{config.author});
    print("   Location: {s}\n\n", .{config.output_dir});

    createScaffold(config) catch |err| {
        switch (err) {
            ScaffoldError.ProjectExists => {
                print("Error: Project directory already exists: {s}\n", .{config.output_dir});
                print("       Use --force to overwrite\n", .{});
            },
            ScaffoldError.InvalidProfile => {
                print("Error: Invalid profile: {s}\n", .{config.profile_name});
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

    print("✅ Created {s}\n", .{project_name});
    print("✅ Generated {d} files from {s} profile\n", .{ profile.files.len, profile.name });
    if (config.init_git) {
        print("✅ Initialized git repository\n", .{});
    }

    print("\nNext steps:\n", .{});
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
