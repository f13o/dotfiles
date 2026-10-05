---
name: pr-draft
description: Draft a PR description from the current branch's changes
user-invocable: true
---

# Draft PR Description

Generate a concise PR description based on the current branch's changes.

## Process

1. Run `git log main..HEAD --oneline` and `git diff main...HEAD --stat` to understand
   what changed
2. Look for a PR template at `.github/PULL_REQUEST_TEMPLATE.md` in the repo root.
   If it does not exist, use the default template from this skill's folder at
   `claude/.claude/skills/pr-draft/DEFAULT_TEMPLATE.md`
3. Fill in the template sections following these guidelines:

### Context

- One or two sentences explaining **why** this change exists (the problem or goal)

### Changelog

- Bulleted list of **what** changed, grouped logically
- Each bullet should be a single short line
- No implementation details unless they matter to reviewers

### QA

- Steps to replicate or verify the change
- List test commands run and their results if applicable
- No screenshots unless the user provides them

## Rules

- Be maximally concise -- no filler words, no restating the obvious
- Write for reviewers who know the codebase
- Output ONLY the filled-in template as markdown, ready to paste
- After outputting the draft, copy it to the clipboard using `echo '...' | pbcopy`
