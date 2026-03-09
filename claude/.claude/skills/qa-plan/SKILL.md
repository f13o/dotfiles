---
name: qa-plan
description: Create or update a QA plan based on specs. Use when the user wants to build a manual QA test plan for a workflow, feature, or spec.
disable-model-invocation: true
argument-hint: [plan-name] [spec-paths...]
---

Create a QA plan for manual testing based on the given specs.

Arguments: `$ARGUMENTS`

Parse arguments: first token is the plan name, remaining tokens are spec file paths or
glob patterns to read.

# Steps

1. **Parse arguments.** Extract `plan-name` (first arg) and spec paths (remaining args).
   If no plan name is given, ask the user. If no spec paths are given, ask the user
   which specs to base the plan on.

1. **Read the specs.** Load each spec file into context. Identify the key requirements
   and scenarios that need manual verification.

1. **Read relevant source files.** Based on what the specs describe, read the
   implementation files to understand current behavior and identify what's testable.

1. **Create the QA directory.** The plan lives at `qa/<plan-name>/` relative to the
   project root (cwd). Create the directory if it doesn't exist. If a `QA.md` already
   exists there, read it first -- you are updating, not replacing from scratch.

1. **Write `QA.md`.** The plan file must follow this structure:

   ```markdown
   # QA: <Plan Name>

   <2-3 sentence overview of the flow being tested and why it matters.>

   ## Prerequisites

   - What must exist before testing (config files, services, data)
   - Environment setup needed

   ## Fixtures

   List any files in this QA folder that support the test (templates, sample configs, etc).
   If fixtures are needed, create them as sibling files in the same `qa/<plan-name>/` folder.

   ## Steps

   ### A. <Section name>

   <Brief description of what this section tests.>

   - [ ] 1. <Concrete action to take> -- <expected outcome>
   - [ ] 2. ...

   ### B. <Section name>

   ...

   ## Findings

   _(populated during execution by /qa-execute)_
   ```

1. **Create fixture files** if the plan needs them. These are minimal files that help
   the human tester: sample configs, TOML templates, scripts to set up/teardown state.
   Place them in `qa/<plan-name>/` alongside `QA.md`.

1. **Report.** Show the user the plan location and a summary of sections and step count.

# Guidelines

- Each step must be **atomic**: one action, one expected outcome.
- Steps must be ordered so a human can follow them sequentially.
- Group steps into lettered sections (A, B, C...) by sub-flow or context (e.g., "inside
  a project" vs "outside a project").
- Include negative tests (error paths, missing files, invalid input).
- The plan must be self-contained: a tester with access to the codebase and the
  prerequisites should be able to execute it without reading specs.
- Keep steps concrete -- use actual command examples, not abstract descriptions.
- When updating an existing plan, preserve the Findings section content.

# Completion

The plan is complete when:

- `qa/<plan-name>/QA.md` exists with all sections filled
- Any needed fixture files are created
- The user is shown the plan summary
