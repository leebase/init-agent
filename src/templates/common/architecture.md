# {{PROJECT_NAME}} Architecture

> **Architecture Decision Records (ADRs) and technical overview.**

---

## System Overview

```
┌─────────────────────────────────────┐
│           {{PROJECT_NAME}}            │
├─────────────────────────────────────┤
│  Component A  │  Component B        │
├─────────────────────────────────────┤
│  Shared / Utilities                 │
└─────────────────────────────────────┘
```

---

## Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Language | {{PROFILE}} | Project profile |
| Runtime | [version] | Compatibility |
| Testing | [framework] | Standard for {{PROFILE}} |
| Build | [tool] | Standard tooling |

---

## Directory Structure

```
{{PROJECT_NAME}}/
├── src/                    # Source code
│   ├── main.{{EXT}}       # Entry point
│   └── ...
├── tests/                  # Test files
├── docs/                   # Documentation
└── [config files]         # Profile-specific
```

---

## Architecture Decision Records

### ADR-001: [Decision Title]

**Status**: Proposed / Accepted / Deprecated

**Context**:
What is the issue that we're seeing that is motivating this decision?

**Decision**:
What is the change that we're proposing or have agreed to implement?

**Consequences**:
- Positive: Benefits of this decision
- Negative: Trade-offs and risks

**Date**: {{DATE}}

---

### ADR-002: [Next Decision]

[Template same as above]

---

## Component Details

### Component A

**Responsibility**: [description]

**Interface**:
```
Input:  [description]
Output: [description]
```

**Dependencies**: [list]

### Component B

[Same structure]

---

## Data Flow

```
[Input] → [Process A] → [Process B] → [Output]
              ↓
         [Storage]
```

---

## Error Handling Strategy

1. Error type 1: [handling approach]
2. Error type 2: [handling approach]

---

## Performance Considerations

- Target: [metric]
- Bottlenecks: [potential issues]
- Optimizations: [planned]

---

*Architecture guide created on {{DATE}}*
