const std = @import("std");

const VERSION = "0.1.0";
const PROJECT_NAME = "{{PROJECT_NAME}}";

const CliError = error{
    InvalidArgument,
    MissingArgument,
    UnknownCommand,
};

fn printUsage(writer: anytype) !void {
    try writer.print(
        \\\Usage: {s} [OPTIONS] [COMMAND]
        \\\
        \\Options:
        \\  -h, --help     Show this help message
        \\  -v, --version  Show version information
        \\\
        \\Commands:
        \\  hello          Print a greeting message
        \\\
        \\
, .{PROJECT_NAME});
}

fn printVersion(writer: anytype) !void {
    try writer.print("{s} version {s}\n", .{ PROJECT_NAME, VERSION });
}

fn printHello(writer: anytype, name: []const u8) !void {
    try writer.print("Hello from {s}, {s}!\n", .{ PROJECT_NAME, name });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    // Get command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // No arguments provided
    if (args.len == 1) {
        try printUsage(stdout);
        return;
    }

    // Parse arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            try printUsage(stdout);
            return;
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--version")) {
            try printVersion(stdout);
            return;
        } else if (std.mem.eql(u8, arg, "hello")) {
            const name = if (i + 1 < args.len) args[i + 1] else "world";
            try printHello(stdout, name);
            return;
        } else {
            try stderr.print("Error: Unknown argument '{s}'\n\n", .{arg});
            try printUsage(stderr);
            return CliError.InvalidArgument;
        }
    }
}

test "basic functionality" {
    // Basic test to verify the project compiles and tests run
    const testing = std.testing;
    try testing.expectEqualStrings("{{PROJECT_NAME}}", PROJECT_NAME);
    try testing.expectEqualStrings("0.1.0", VERSION);
}
