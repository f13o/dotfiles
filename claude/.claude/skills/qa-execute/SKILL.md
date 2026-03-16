---
name: qa-execute
description: Execute a QA plan step by step with a human tester. Use when the user wants to run through a QA plan, report results, and generate a findings report.
disable-model-invocation: true
argument-hint: [plan-name]
---

Execute a QA plan interactively with a human tester.

Arguments: `$ARGUMENTS`

The first argument is the plan name (folder name under `qa/`). If not given, list
available plans in `qa/` and ask the user to pick one.

# Steps

1. **Load the plan.** Read `qa/<plan-name>/QA.md`. Also read any fixture files in the
   same folder. If the plan doesn't exist, list available `qa/*/QA.md` and ask the user
   to choose.

1. **Create the run folder.** Create `qa/<plan-name>/runs/YYYY-MM-DD-HHmm/` using the
   current date and time. Copy `QA.md` and all other files from `qa/<plan-name>/` (except
   the `runs/` directory) into the run folder. All work during this execution happens
   inside the run folder -- the template folder is never modified.

1. **Show overview.** Print the plan title, overview, prerequisites, and the run folder
   path. Ask the user to confirm prerequisites are met before continuing.

1. **Walk through steps sequentially.** For each step in the plan:

   a. Print the step number, action, and expected outcome clearly.

   b. Ask the user to execute the step and report what happened. Use AskUserQuestion
   with a text field. Suggested prompt:
   `"Step <N>: <action summary>. What happened? (pass / fail + details / skip)"` Hint
   the user to include UX observations: Was the output confusing? Was an error message
   unhelpful? Did they have to guess what a value meant? Was timing surprising?

   c. Record the result:

   - **pass**: Step worked as expected.
   - **fail**: Something didn't match. Capture the user's description of what went
     wrong.
   - **skip**: User chose to skip (record reason if given).
   - **ux**: User reports confusion, unclear output, bad error message, or friction even
     if the step technically passed. Record as pass + UX note.

   d. **When the user asks a question** ("what does this mean?", "I don't understand
   this output", "what's this value?", etc.):

   - Do NOT answer the question or investigate. This is a QA session, not debugging.
   - Record the question verbatim as a UX finding for that step.
   - Say: "Recorded as a UX finding. The fact that this isn't clear is the signal."
   - If the question is **blocking** (user literally cannot continue without an answer),
     then briefly explain only what is needed to unblock them based on the expected
     outcome from the plan, and still record the question as a UX finding.

   e. Move to the next step. Do NOT fix anything during execution -- just record.

1. **Update the run's QA.md.** After all steps are done (or user says stop), update the
   `QA.md` inside the run folder:

   a. Check each step's checkbox (`- [x]` for pass, leave `- [ ]` for fail/skip).

   b. Append a `## Findings` section at the end with the execution results.

1. **Write `REPORT.md`.** Create `REPORT.md` in the run folder with a structured report:

   ```markdown
   # QA Report: <Plan Name>

   **Executed:** YYYY-MM-DD
   **Run:** `runs/YYYY-MM-DD-HHmm/`
   **Result:** X/Y passed, Z failed, W skipped, U UX issues

   ## Failures

   | # | Step | Expected | Actual |
   |---|------|----------|--------|
   | N | <step summary> | <expected from plan> | <what user reported> |

   ## UX Issues

   | # | Step | Observation |
   |---|------|-------------|
   | N | <step summary> | <user's confusion, question, or friction verbatim> |

   ## Skipped

   | # | Step | Reason |
   |---|------|--------|
   | N | <step summary> | <reason> |
   ```

   Always include all three sections. When a section has no entries, keep the table header
   and write a single row: `| - | None | - |` (or equivalent for the column count).

1. **Show summary.** Print the pass/fail/skip counts, list failures with their step
   numbers, and show the run folder path.

# Guidelines

- Never fix bugs during execution. The goal is to record, not repair.
- Keep the interaction tight: one step at a time, one question at a time.
- If the user says "stop" or "abort" mid-plan, generate the report with what you have so
  far. Mark remaining steps as skipped with reason "aborted".
- If a step fails, ask the user if they want to continue or stop.
# Completion

Execution is complete when:

- Run folder `qa/<plan-name>/runs/YYYY-MM-DD-HHmm/` exists with all files
- The run's `QA.md` has checkboxes checked and Findings section appended
- `REPORT.md` is written in the run folder (always include all sections -- Failures, UX
  Issues, Skipped -- even when empty, so the report is explicitly "no failures" rather
  than silently omitting them)
- Summary is shown to the user with the run folder path
