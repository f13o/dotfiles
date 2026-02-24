---
name: roast
description: Analyze a skill for ambiguities, missing validation, unclear instructions, and potential LLM confusion
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
argument-hint: [skill-name or path]
---

Analyze the skill "$0" for precision issues and potential ambiguities. Validate
arguments, locate and read the skill file, then evaluate against focus areas.

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
1. If `$0` is a relative path:
   - If it ends in `.md`, resolve relative to current working directory and read that
     file
   - Otherwise, treat as directory, resolve relative to current working directory, and
     append `/SKILL.md`
1. If `$0` is a skill name (no path separators):
   - Check `.claude/skills/$0/SKILL.md` (relative to current working directory)

If skill not found in any location:

- Exit with error: "Skill '$0' not found in .claude/skills/"
- DO NOT proceed with analysis

# Analysis Focus

Once the skill file is successfully read, evaluate:

## Core Questions

1. **Is it accurate enough?**

   - Does the skill achieve its stated purpose?
   - Are there ambiguities that could cause wrong outcomes?

1. **Would more precision improve results?**

   - Where does vagueness cause LLM to guess incorrectly?
   - What constraints would meaningfully improve success rate?

1. **What's the trade-off?**

   - What flexibility is lost with added precision?
   - Is the restriction worth the gained certainty?

1. **Is anything over-complicated?**

   - Are there overly restrictive statements that could backfire?
   - Where does excessive precision create brittleness or block valid use cases?

## What Could Actually Go Wrong

Focus on practical failure modes:

- **Wrong execution**: Instructions that could be interpreted multiple ways, leading to
  different actions
- **Silent failures**: Missing validation that causes errors to go unnoticed
- **Scope creep**: Unbounded operations that do more than intended
- **Unsafe operations**: Destructive actions without guards
- **LLM confusion**: Ambiguity where the model genuinely can't tell what's expected
- **Over-restriction**: Excessive precision that blocks valid use cases or creates
  brittleness

Ignore edge cases that don't affect the skill's intention or theoretical issues that
won't occur in practice.

# Red Flags

Look for these patterns that cause real problems:

1. **Best-effort inference**: Guessing instead of failing when inputs missing
1. **Vague scope**: Unbounded operations without clear stopping points
1. **Ambiguous conditionals**: "If needed" without criteria for when that is
1. **Silent failures**: Not validating preconditions that will cause errors later
1. **Tool permission gaps**: Unrestricted tools for specific tasks
1. **Over-specification**: Hardcoded patterns/values that prevent valid alternatives

# Output Format

Present findings as a brief summary:

## Assessment

**Accuracy**: [Sufficient | Needs Work] **Intent**: (One-line description of what skill
is trying to accomplish)

## What Could Go Wrong

For each practical issue found:

1. Issue #number

- **Line X**: Brief problem description
- **Impact**: How this affects the skill's outcome
- **Fix**: Concise suggestion (1 line)
- **Trade-off**: What flexibility is lost (if any)

## Over-Complicated Statements

Identify overly restrictive or brittle statements found:

- **Line X**: What's too restrictive
- **Backfire risk**: How this could block valid use cases
- **Simplify**: Suggest looser alternative

## Performance Optimizations

Optional precision improvements that make LLM execution more certain but aren't
required:

- Brief suggestion with trade-off noted

Keep observations focused and concise. Skip theoretical issues.

# Examples

**Problematic**: "Fix the issue in $0"

- Impact: "issue" undefined, LLM will guess what to fix
- Fix: "Read $0 and fix [specific thing]"

**Problematic**: "Find relevant files"

- Impact: "Relevant" is subjective, inconsistent results
- Fix: Only if specificity matters for outcome - otherwise fine for exploratory tasks

**Problematic**: "Check if tests pass"

- Impact: No failure handling, LLM might just report instead of analyzing
- Fix: Only if subsequent steps depend on pass/fail - otherwise "check" is adequate

**Over-complicated**: "Use Grep with pattern '^test\_.\*.py$' and output_mode
'files_with_matches' to find test files"

- Backfire: Blocks alternative test file patterns like `*_test.py` or `test*.py`
- Simplify: "Find test files" (let LLM choose approach) or "Use Glob with pattern
  '\*\*/*test*.py'"

# Execution

1. Validate `$0` is provided (exit if not)
1. Locate the skill file (exit if not found)
1. Read the SKILL.md file
1. Identify what the skill is trying to accomplish
1. Find all practical issues that could cause wrong outcomes (report all significant
   issues found, typically 2-5, but could be less)
1. Identify over-complicated or overly restrictive statements (report all found,
   typically 2-3)
1. Note any performance optimizations (optional precision)
1. Present concise summary
