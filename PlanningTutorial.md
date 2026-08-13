<a id="top"></a>
# Plan Before You Code: Guiding AI Assistants

This tutorial is for developers who use AI coding assistants (like Antigravity or AgentFlow setups) and want to get more reliable results on complex features.

When working with an AI, the temptation is strong to dump a prompt and say, "Build this." But diving straight into code without shared context or architectural agreement usually results in wasted tokens, broken architectures, and frustrating rewrites.

By the end of this guide, you will understand the "Plan Before You Code" workflow: a disciplined four-step method for loading target context, establishing constraints, and forcing the AI to generate an explicit technical plan before it writes a single line of code.

---

## Table of Contents

- [Section 1: Building Shared Understanding](#section-1-building-shared-understanding)
  - [1.1 Context Loading: The Source Material](#11-context-loading-the-source-material)
  - [1.2 Context Loading: The Target Environment](#12-context-loading-the-target-environment)
- [Section 2: Establishing Constraints and Planning](#section-2-establishing-constraints-and-planning)
  - [2.1 Setting Architectural Constraints](#21-setting-architectural-constraints)
  - [2.2 Generating the Implementation Plan](#22-generating-the-implementation-plan)
- [Section 3: Execution](#section-3-execution)
  - [3.1 Approving the Plan and Watching the Build](#31-approving-the-plan-and-watching-the-build)

---

<a id="section-1-building-shared-understanding"></a>
## Section 1: Building Shared Understanding

If you want an AI to port a feature from one codebase to another, or build a new feature that respects your existing patterns, you must explicitly load that context first. Do not bundle the context and the build request into the same prompt.

### 1.1 Context Loading: The Source Material
Start by pointing the AI at your reference material. For example, if you are porting an architecture from an older repository, explicitly ask the AI to "come up to speed" on that repository first.

Wait for the AI to reply. It should provide a summary of its findings, confirming it understands the original structure (e.g., identifying a 10-agent orchestrator pipeline).

### 1.2 Context Loading: The Target Environment
Once the AI understands the *source*, point it at the *target*. Instruct it to explore the current project you are working in. Ask it to read the relevant tooling, file structures, and methodology documents.

Again, wait for the AI to confirm its understanding of the new constraints (e.g., recognizing that the new project is a Zig CLI tool with embedded templates).

[Back to top](#top)

---

<a id="section-2-establishing-constraints-and-planning"></a>
## Section 2: Establishing Constraints and Planning

Now that the AI understands both the source logic and the target environment, you must have a conversation about *how* the feature should be built before authorizing the build.

### 2.1 Setting Architectural Constraints
Discuss the design approach. Should the new feature be monolithic or modular? Should it rely on an external orchestrator, or use a simpler, sequential single-agent approach?

Working through these questions prevents the AI from making sweeping, incorrect assumptions about your preferred architecture.

### 2.2 Generating the Implementation Plan
Once the strategy is clear, command the AI to draft an Implementation Plan. This should be a step-by-step technical proposal detailing exactly what files it will create, modify, or delete, and broad strokes of the logic it intends to write.

This plan serves as your **Approval Gate**.

[Back to top](#top)

---

<a id="section-3-execution"></a>
## Section 3: Execution

The execution phase should be the simplest part of the session if the previous steps were followed correctly.

### 3.1 Approving the Plan and Watching the Build
Review the implementation plan. If it looks wrong, point out the flaws and ask the AI to revise the plan.

Once the plan is strictly what you want, explicitly approve it. The AI will then execute the technical stages cleanly, following the roadmap it just authored, resulting in a successful build on the first attempt.

[Back to top](#top)
