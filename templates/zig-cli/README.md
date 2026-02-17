# {{PROJECT_NAME}}

A Zig CLI tool created on {{DATE}} by {{AUTHOR}}.

## Description

{{PROJECT_NAME}} is a command-line tool built with Zig.

## Building

```bash
# Build the project
zig build

# Build in release mode
zig build -Doptimize=ReleaseFast
```

## Running

```bash
# Run with zig build
zig build run

# Run with arguments
zig build run -- --help

# Run the compiled binary
./zig-out/bin/{{PROJECT_NAME}} --help
```

## Testing

```bash
# Run all tests
zig build test

# Run tests in a specific file
zig test src/main.zig
```

## Project Structure

```
.
├── build.zig      # Build configuration
├── src/
│   └── main.zig   # Main entry point
└── README.md      # This file
```

## License

Add your license information here.
