# Chat Transcript: Porting Tutorial Writer to init-agent

**USER:** I built some tutorial agents in this project (lunduke-transcripts) that I want to copy to my init-agents project, but before I do, I want to understand them. My goal is a tutorial writer skill that will spawn a team of skilled writers, can you start by coming up to speed on the skills I have in this project

**AI:** [Analyzed the `lunduke-transcripts` project. Found a 10-agent, 22-skill pipeline coordinated by a Python application. The agents handle interpretation, planning, evidence mapping, visual selection, writing, validation, and multi-stage review.]

**USER:** take a look at ~/projects/init-agent it's my "project kick starter" that loads my agents.md and related files for my AgentFlow methodology, let's ignore the orchestrator for the moment

**AI:** [Analyzed `init-agent`. It's a Zig CLI tool that uses a `--profile` system to scaffold projects (e.g., python, web-app) with templates containing `AGENTS.md` and standard workflow files. Note: there are two template trees, `templates/` for the repo itself and `src/templates/` compiled into the Zig binary.]

**USER:** I want both, but we can start with option A, but before we add the skills, I want to discuss how I would use one. For example, I want to create a tutorial on skills, using the tutorial writer skills as an example. Will there be such a high level skill that will call the others, or is that only available with an orchestrator?

**AI:** Yes, we can create a single high-level "coordinator" skill (e.g., `tutorial-writer.md`) that guides ONE agent through the entire pipeline sequentially. You would point the agent at this single skill, and it would tell the agent when to load the other sub-skills and what role to put on (Model 1 autonomy).

**USER:** let's go with modular and model 1 for now. I am playing around with Symphony for orchestration and with building my own. This first need is to add some tutorial writing smarts to init-agent. I like the idea of the profile you mentioned. init-agent will just load the normal skills, and a call to load the tutorial writing profile would be a second call and/or a command line option for the initial call. I just need the skills to be usuable outside of the Lunduke orchestrator first

**AI:** [Drafted an implementation plan to create `templates/tutorial-writer/`. The plan involves:
1. Creating `skills/tutorial-writer.md` (the new coordinator with a human approval gate for the outline).
2. Porting 17 sub-skills and removing lunduke-specific artifact names (like `tutorial_asset_bundle.json` or `--approve-outline`).
3. Porting the 10 agent role files.]

**USER:** [Approved the implementation plan]

**AI:** [Created 18 skill files and 10 agent files in `templates/tutorial-writer/`. Removed all lunduke-specific concepts. Visuals in the `frame-selection.md` skill were made explicitly optional. Wrote a walkthrough artifact and updated `sprint-plan.md`.]
Done. Here's what landed in `init-agent`:
`templates/tutorial-writer/skills/` (18 files including the new coordinator)
`templates/tutorial-writer/agents/` (10 role files)

**USER:** you copied over the files, but didn't build the profile into init_agent?

**AI:** Fair point. I'll wire it into the Zig source.
[Copied the 28 files from `templates/tutorial-writer/` into `src/templates/tutorial-writer/`.
Modified `src/main.zig`:
1. Added 28 `@embedFile` constants for the new files.
2. Created the `TUTORIAL_WRITER_PROFILE` struct containing those files and target directories.
3. Registered it in the `getProfile()` function.
4. Added it to the list in `printProfiles()`.
Modified `product-definition.md` to document the new `tutorial-writer` profile.]
Done. The profile is fully wired in. You can test it by running `zig build` and then `init-agent my-tutorial --profile tutorial-writer`.

**USER:** Take this entire conversation and create a PlanningTutorial.md that I will use to test the tutorial writer
