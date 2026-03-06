# Skill: Development Loop

> Load this skill when implementing any feature or fix for init-agent.

---

## The Loop

Every piece of work follows this sequence. **Do not skip or reorder steps.**

```
1. CODE        → Write the implementation
2. TEST        → Run automated tests
3. TEST AS LEE → Simulate the real user workflow (see skills/test-as-lee.md)
4. FIX         → Repair everything that failed
5. LOOP        → Repeat 2–4 until everything passes clean
6. DOCUMENT    → Update project docs (see skills/documentation.md)
7. COMMIT      → Stage, commit, push
```

---

## Template File Rule (Critical for init-agent)

This project has **two template trees**. When you edit any template:

1. Edit `templates/common/` or `templates/<profile>/` (human-editable source of truth)
2. Copy the changed file to the matching path under `src/templates/` (what gets compiled in)

If you edit only one, the compiled binary will not reflect your changes.

```bash
# After editing a template, always sync:
cp templates/common/agent.md src/templates/common/agent.md
cp templates/common/skills/foo.md src/templates/common/skills/foo.md
# etc.
```

---

## How to Write Code Well

**Start with the interface, not the internals.**
For init-agent, this means: define the CLI flag, target path, and embedded content before writing the Zig wiring. If you're adding a template, write the template file first, then the `@embedFile` and profile entry.

**Build the smallest working thing first.**
Add one template to one profile. Verify the build. Verify the scaffold output. Then extend to the other profiles.

**Handle errors explicitly.**
Zig's error unions require you to handle every failure path. Do not use `catch unreachable` except where genuinely unreachable. Prefer `catch |err| { print(...); return ScaffoldError.IoError; }` with a clear message.

**On Zig 0.13.0 API:**
- `ArrayList.init(allocator)` — not `.empty`
- `list.append(item)` — not `list.append(allocator, item)`
- `list.deinit()` — not `list.deinit(allocator)`
- `list.toOwnedSlice()` — not `list.toOwnedSlice(allocator)`

---

## How to Test

```bash
# Compile (must pass — this is failing test #1 if it doesn't)
/home/lee/zig/zig build -Doptimize=ReleaseFast

# Run unit tests (17 test cases covering replaceAll, substituteVariables, etc.)
/home/lee/zig/zig build test

# Integration smoke test: generate a real project and inspect it
./zig-out/bin/init-agent test-project --profile python --force
ls test-project/skills/
ls test-project/code-reviews/
cat test-project/AGENTS.md | head -20
rm -rf test-project

# Test --update on existing project
mkdir -p update-test && ./zig-out/bin/init-agent update-test --profile python --force
./zig-out/bin/init-agent --update --profile python --dir update-test
ls update-test/skills/
rm -rf update-test
```

---

## What Commit Means

```bash
git add -A -- ':!tmp-init-agent-smoke' ':!dist/*.tar.gz'
git commit -m "type: short description"
git push
```

**Types:** `feat:` `fix:` `docs:` `refactor:` `test:`

**Good:** `feat: add code-review skill to all profiles`
**Bad:** `update stuff`

---

## When to Stop and Ask

- A design decision would affect the public CLI interface
- You've hit the same Zig compiler error three times and don't understand it
- A template change would break backward compatibility for existing projects

*Last updated: 2026-03-05*
