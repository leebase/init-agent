<a id="top"></a>
# Building a Modular Agent Profile for init-agent

This tutorial is for developers and users of the `init-agent` tool who want to extend its capabilities by building and integrating a complex, multi-stage "profile". It will walk you through the process of taking a modular set of AI skills and packaging them into a new profile (in this case, a "tutorial-writer") that can be scaffolded natively by the `init-agent` Zig binary.

By the end of this guide, you will understand how to design a "Model 1 Autonomy" coordinator skill and wire it directly into the `init-agent` CLI tool.

---

## Table of Contents

- [Section 1: Designing the AgentFlow Profile](#section-1-designing-the-agentflow-profile)
  - [1.1 Define the Coordinator Skill](#11-define-the-coordinator-skill)
  - [1.2 Package the Sub-skills and Roles](#12-package-the-sub-skills-and-roles)
  - [1.3 Generalize the Artifacts](#13-generalize-the-artifacts)
- [Section 2: Wiring the Profile into init-agent](#section-2-wiring-the-profile-into-init-agent)
  - [2.1 Embed the Template Files](#21-embed-the-template-files)
  - [2.2 Construct the Profile Struct](#22-construct-the-profile-struct)
  - [2.3 Register the Profile](#23-register-the-profile)
  - [2.4 Document the New Capability](#24-document-the-new-capability)

---

<a id="section-1-designing-the-agentflow-profile"></a>
## Section 1: Designing the AgentFlow Profile

Before writing code, we need to structure the skills in a way that allows a single agent to execute a complex pipeline. This is often referred to as "Model 1 Autonomy"—where one AI agent puts on different hats sequentially rather than relying on a multi-agent orchestrator.

### 1.1 Define the Coordinator Skill
The foundation of a Model 1 pipeline is the "coordinator skill". This is a high-level markdown file (e.g., `tutorial-writer.md`) that acts as the master instruction set. If you point an agent at this single skill, it provides the ordered stages, telling the agent when to load other sub-skills, when to adopt a specific role, and when to pause for human approval.

### 1.2 Package the Sub-skills and Roles
To keep the coordinator skill readable, the individual tasks are broken out into separate sub-skills and agent role files.
You must package these cleanly into the `init-agent` template directory structure:
- `templates/<profile-name>/skills/` (e.g., placing your 18 sub-skills here)
- `templates/<profile-name>/agents/` (e.g., placing the 10 role files here)

### 1.3 Generalize the Artifacts
If you are porting these skills from another project or script, ensure you remove any project-specific concepts or artifact names. For example, if a skill originally referenced hardcoded json files from a previous workflow, rewrite it to be generic so it functions correctly regardless of where `init-agent` scaffolds it.

[Back to top](#top)

---

<a id="section-2-wiring-the-profile-into-init-agent"></a>
## Section 2: Wiring the Profile into init-agent

With the markdown files packaged in the `templates/` directory, the next step is to ensure `init-agent` actually compiles them into its executable binary.

### 2.1 Embed the Template Files
Open your `src/main.zig` file. Zig uses the `@embedFile` built-in function to bundle static assets. You need to add an `@embedFile` constant for every new skill and agent markdown file added in Section 1.

### 2.2 Construct the Profile Struct
Once the files are embedded, organize them by defining a new profile struct (e.g., defining `TUTORIAL_WRITER_PROFILE`). This struct maps those newly embedded files to their intended target directories so `init-agent` knows where to place them during scaffolding.

### 2.3 Register the Profile
With the struct created, it must be registered within the `init-agent` routing logic.
1. Add the new struct to the `getProfile()` function. This binds the profile to a command-line flag like `--profile tutorial-writer`.
2. Append the new profile to the `printProfiles()` list so it appears when a user queries the available options.

### 2.4 Document the New Capability
Finally, update the project's documentation, such as `product-definition.md` or the main `README.md`, to expose the new profile. This ensures users know the capability exists and how to invoke it.

[Back to top](#top)
