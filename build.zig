const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get version from git tags at build time
    const version = getVersionFromGit(b);

    // Create module for the executable
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create build options for the executable module
    const exe_options = b.addOptions();
    exe_options.addOption([]const u8, "version", version);
    exe_mod.addImport("build_options", exe_options.createModule());

    const exe = b.addExecutable(.{
        .name = "init-agent",
        .root_module = exe_mod,
    });

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
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add build options to test module as well
    const test_options = b.addOptions();
    test_options.addOption([]const u8, "version", version);
    test_mod.addImport("build_options", test_options.createModule());

    const exe_unit_tests = b.addTest(.{
        .name = "init-agent-test",
        .root_module = test_mod,
    });

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
