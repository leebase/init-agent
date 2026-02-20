const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get version from git tags at build time
    const version = getVersionFromGit(b);

    // Create options module
    const options = b.addOptions();
    options.addOption([]const u8, "version", version);
    const options_module = options.createModule();

    const exe = b.addExecutable(.{
        .name = "init-agent",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("build_options", options_module);

    // Install the executable
    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run init-agent");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unit_tests.root_module.addImport("build_options", options_module);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

/// Get version from git tags, or fallback to commit hash, or "dev" if not in git
fn getVersionFromGit(b: *std.Build) []const u8 {
    const result = std.process.Child.run(.{
        .allocator = b.allocator,
        .argv = &.{ "git", "describe", "--tags", "--always" },
        .cwd = b.build_root.path,
    }) catch return "dev";

    if (result.term == .Exited and result.term.Exited == 0) {
        const trimmed = std.mem.trim(u8, result.stdout, " \n\r\t");
        if (trimmed.len > 0) {
            return b.dupe(trimmed);
        }
    }

    return "dev";
}
