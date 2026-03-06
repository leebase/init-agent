# Skill: Test As Lee

> Load this skill before presenting any feature to Lee for review.

---

## The Goal

When Lee sits down to run init-agent, **he should be focused on whether it does the right thing** — not on debugging crashes, wrong file paths, or garbled output. Find every embarrassing failure before he touches it.

---

## The Protocol

### Step 1: Build successfully

```bash
/home/lee/zig/zig build -Doptimize=ReleaseFast
```

If this fails, stop. The tool doesn't exist yet.

### Step 2: Run unit tests

```bash
/home/lee/zig/zig build test
```

All 17 tests must pass. A single test failure means something is broken.

### Step 3: Scaffold a fresh project — all 3 profiles

```bash
./zig-out/bin/init-agent test-python --profile python --force
./zig-out/bin/init-agent test-webapp --profile web-app --force
./zig-out/bin/init-agent test-zig --profile zig-cli --force
```

For each, verify:
- `AGENTS.md` exists and has the correct project name (not `{{PROJECT_NAME}}`)
- `skills/` directory exists with all 5 skill files
- `code-reviews/` directory exists
- `backlog/candidates/`, `backlog/approved/` etc. exist
- Profile-specific files exist (`pyproject.toml` for python, `package.json` for web-app, `build.zig` for zig-cli)
- No `Warning: Unresolved placeholders` for the standard variables (PROJECT_NAME, AUTHOR, DATE, PROFILE are fine to check; the `{{TEST_COMMAND}}` ones in skills are intentional)

```bash
ls test-python/skills/
cat test-python/AGENTS.md | head -5    # Should say "# Agent Guide: test-python"
ls test-python/code-reviews/
```

### Step 4: Test --dry-run

```bash
./zig-out/bin/init-agent dry-test --profile python --dry-run
```

Should print `[DRY RUN]` lines for every file without creating any files or directories.

### Step 5: Test --update on existing project

```bash
# Simulate updating an old project that has no skills/ dir
mkdir -p old-project && cd old-project && git init && cd ..
./zig-out/bin/init-agent --update --profile python --dir old-project
ls old-project/skills/     # Must now exist with all 5 skill files
```

### Step 6: Test edge cases

```bash
# Force overwrite
./zig-out/bin/init-agent test-python --profile python --force
echo "Exit: $?"    # Must be 0

# Piped stdin (no runaway process)
echo "" | timeout 5 ./zig-out/bin/init-agent already-exists --profile python
echo "Exit: $?"    # Must complete within 5 seconds

# Unknown profile
./zig-out/bin/init-agent bad-test --profile nonexistent
echo "Exit: $?"    # Should print error and exit cleanly — not crash

# --list
./zig-out/bin/init-agent --list
```

### Step 7: Clean up

```bash
rm -rf test-python test-webapp test-zig dry-test old-project bad-test already-exists
```

---

## The "Would Lee Be Embarrassed" Test

Before calling it done:
- Does any generated file contain a raw `{{PROJECT_NAME}}` or `{{DATE}}`? (Substitution bug)
- Does the binary hang on any of the edge case inputs above?
- Does `--list` show all 3 profiles?
- Does the success output look clean and professional?

If anything fails — go back to CODE. Do not document or commit broken work.

*Last updated: 2026-03-05*
