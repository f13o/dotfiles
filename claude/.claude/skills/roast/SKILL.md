---
name: roast
description: Analyze a skill for ambiguities, missing validation, unclear instructions, and potential LLM confusion
disable-model-invocation: true
allowed-tools: Read, Glob
argument-hint: [skill-name or path]
---

Analyze the skill "$0" for precision issues and potential ambiguities.

# Validation Rules

## 1. Argument Validation

CRITICAL: If `$0` is empty or not provided:

- DO NOT proceed with analysis
- DO NOT infer or guess which skill to analyze
- Exit immediately with error: "No skill specified. Usage: /roast [skill-name or path]"

If the skill path/name is provided, continue with analysis.

## 2. Locate the Skill

Search in this order:

1. If `$0` is an absolute path, read that file directly
1. If `$0` is a relative path, resolve from current directory
1. If `$0` is a skill name (no path separators):
   - Check `.claude/skills/$0/SKILL.md`
   - Check `~/.claude/skills/$0/SKILL.md`

If skill not found in any location:

- Exit with error: "Skill '$0' not found in .claude/skills/ or ~/.claude/skills/"
- DO NOT proceed with analysis

# Analysis Checklist

Once the skill file is successfully read, analyze for:

## Input Validation Issues

- [ ] Does the skill accept arguments but fail to validate they exist?
- [ ] Does it use `$0`, `$1`, etc. without checking if they're provided?
- [ ] Does it use `$ARGUMENTS` without verifying it's not empty?
- [ ] Should it exit early if required arguments are missing?
- [ ] Does it do "best effort" inference when it should fail fast?

## Ambiguous Instructions

- [ ] Are steps vague or open to multiple interpretations?
- [ ] Does it say "check" or "verify" without defining success criteria?
- [ ] Does it use relative terms like "large", "complex", "many" without thresholds?
- [ ] Are conditionals unclear (when to do X vs Y)?
- [ ] Does it assume context the LLM might not have?

## Missing Constraints

- [ ] Should certain tools be restricted via `allowed-tools` but aren't?
- [ ] Should `disable-model-invocation: true` be set (for side effects) but isn't?
- [ ] Are destructive operations possible without explicit guards?
- [ ] Should it use `context: fork` to isolate side effects?

## Unclear Scope

- [ ] Is the goal/outcome of the skill clear?
- [ ] Does it know when to stop?
- [ ] Are success/failure conditions defined?
- [ ] Does it handle edge cases explicitly?

## Tool Usage Precision

- [ ] Does it specify exact tool parameters or leave them vague?
- [ ] Are file paths, patterns, or queries clearly defined?
- [ ] Does it say "find relevant files" without criteria?
- [ ] Does it use "analyze" or "investigate" without specific steps?

## Frontmatter Issues

- [ ] Is `description` clear enough for auto-invocation decisions?
- [ ] Is `argument-hint` present if arguments are used?
- [ ] Are `allowed-tools` appropriately scoped?
- [ ] Should `user-invocable` be false but isn't?

## LLM Confusion Points

- [ ] Could the LLM reasonably interpret instructions differently?
- [ ] Are there implicit assumptions that need to be explicit?
- [ ] Does it rely on "common sense" that varies between models?
- [ ] Are pronouns or references ambiguous?

# Output Format

Present findings as:

## Critical Issues (Must Fix)

- Missing argument validation
- Ambiguous core logic
- Unsafe operations without guards

## Warnings (Should Fix)

- Vague instructions
- Missing constraints
- Unclear success criteria

## Suggestions (Consider)

- Potential edge cases
- Stylistic improvements
- Additional safeguards

## Score

Rate precision on scale: **[Low|Medium|High] Precision**

For each issue, provide:

1. Specific line/section with the problem
1. Why it's problematic for an LLM
1. Concrete fix suggestion

# Anti-Patterns to Flag

1. **Best-effort inference**: Guessing what user meant instead of validating input
1. **Vague scope**: "Analyze the codebase" without boundaries
1. **Implicit assumptions**: Assuming file locations, naming conventions, or context
1. **Undefined success**: No clear end state or completion criteria
1. **Silent failures**: Not exiting when preconditions aren't met
1. **Ambiguous conditionals**: "If needed" or "when appropriate" without criteria
1. **Tool permission gaps**: Allowing Bash without restrictions when specific commands
   expected

# Example Issues

**Bad**: "Fix the issue in $0"

- Problem: No validation that $0 exists; "issue" is undefined
- Fix: "If $0 is empty, exit with error. Read file $0 and identify the specific issue
  described in the request."

**Bad**: "Find relevant files"

- Problem: "Relevant" is subjective
- Fix: "Find all Python files matching pattern \*\*/\*\_test.py using Glob"

**Bad**: "Check if tests pass"

- Problem: No validation logic or exit behavior
- Fix: "Run pytest. If exit code is non-zero, report failures and exit. If exit code is
  0, report success."

# Execution

1. Validate `$0` is provided (exit if not)
1. Locate the skill file (exit if not found)
1. Read the SKILL.md file
1. Analyze against all checklist items
1. Present findings in the output format above
1. Provide actionable fixes for each issue
