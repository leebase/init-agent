---
id: BI-001
title: Auto-detect profile for --update

source: development
source_insight: >
  Running --update requires specifying --profile, but the project already contains files that identify the profile.

opportunity: >
  Users can run `init-agent --update` without --profile and it just works. Reduces friction and eliminates wrong-profile mistakes.

why_now: >
  --update was just shipped. Making it frictionless while the feature is fresh prevents bad habits from forming.

minimal_impl: >
  Check for signature files in cwd: pyproject.toml → python, package.json → web-app, build.zig → zig-cli.
  Fall back to python if ambiguous. Print detected profile in output.

definition_of_done:
  - --update without --profile auto-detects from project files
  - Detected profile printed in output for transparency
  - --profile flag still works as explicit override
  - Error message if no profile can be detected and none specified

effort: S
build_recipe: builder_safe
priority: now

tags:
  - feature
  - ux
  - update

status: candidate
created_at: 2026-02-19T17:44:00Z
created_by: antigravity
token_cost: 0

approved_at: ~
approved_by: ~
notes: ~

implemented_at: ~
implemented_by: ~
pr_url: ~
---

# Additional Context

Detection order:
1. `--profile` flag (explicit override, always wins)
2. Signature file detection:
   - `pyproject.toml` or `setup.py` → python
   - `package.json` → web-app
   - `build.zig` → zig-cli
3. Fall back to error: "Could not detect profile. Use --profile to specify."

Edge case: a project could have both `package.json` and `pyproject.toml` (e.g., a full-stack app). In that case, print a warning and require explicit `--profile`.
