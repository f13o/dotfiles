---
name: codex-adversary
description: Use OpenAI Codex as an adversarial reviewer. Invoke when you want a second opinion, adversarial critique, or red-team feedback on code, designs, or ideas from a different model.
allowed-tools: "Read, Bash(codex *), Bash(CODEX_OUT=$(mktemp *) && codex *), Bash(CODEX_OUT=$(mktemp *); codex *)"
---

You have access to **Codex CLI** (`codex`), an OpenAI-powered coding agent you can run
from the terminal. Use it as an **adversary** — a second model that challenges your
work, finds flaws, and stress-tests your reasoning.

## Availability check (run first)

Before doing anything else in this skill, verify that Codex is installed and functional:

```bash
codex --version
```

- **If the command succeeds** (exit code 0 and prints a version string): proceed with
  the skill normally.
- **If the command fails** (not found, permission denied, or non-zero exit): **stop
  immediately**. Do not attempt any Codex invocations. Instead, inform the user that
  Codex CLI is not available and suggest:
  1. Install it: `npm install -g @openai/codex` (or check the official docs).
  1. Ensure it is in `$PATH`.
  1. Run `codex login` to configure authentication.

Do not retry, do not fall back to running prompts without Codex, and do not silently
skip the adversarial review — the user asked for a second opinion and should know it
cannot be provided.

## When to use Codex

- The user explicitly asks for adversarial review or a second opinion.
- You want to red-team a design decision, implementation, or plan.
- You want an independent code review from a different model.
- You're stuck and want a fresh perspective on a problem.
- After implementing a new public service function or API endpoint.
- Before creating a PR with non-trivial changes.

## Available commands

Before invoking codex, you may run `codex --help` or `codex <subcommand> --help` to
discover the latest options. The key subcommands are:

| Command             | Purpose                                              |
| ------------------- | ---------------------------------------------------- |
| `codex exec`        | Run a prompt non-interactively (primary tool)        |
| `codex exec review` | Run a code review non-interactively (preferred)      |
| `codex features`    | Inspect feature flags (`list`, `enable`, `disable`)  |
| `codex apply`       | Apply the latest diff produced by Codex to your tree |
| `codex resume`      | Resume a previous session                            |

> **Note:** `codex review` exists as a top-level alias but lacks flags like `-m`,
> `--ephemeral`, `-o`, and `--json`. Always prefer `codex exec review` instead — it
> supports all exec flags plus the review-specific ones (`--uncommitted`, `--base`,
> `--commit`, `--title`).

### Discovery

If you're unsure about available options, run:

```bash
codex exec --help
codex exec review --help
codex features list
```

This ensures you use the latest flags rather than relying on stale information.

## Model and reasoning selection

Before invoking Codex, read the user's local configuration so you know which model and
reasoning effort are set:

- Use the **Read tool** to read `~/.codex/config.toml` (do not use `sed` or `cat`).
- The configured defaults are a good baseline. If the user does not ask for a specific
  model or effort, use those defaults without overriding.

### How to override model

Both `codex exec` and `codex exec review` support the `-m/--model` flag:

```bash
codex exec -m <MODEL> ...
codex exec review -m <MODEL> ...
```

### How to override reasoning effort

Reasoning effort is controlled with the config key `model_reasoning_effort`.

```bash
codex exec -c 'model_reasoning_effort="high"' ...
codex exec review -c 'model_reasoning_effort="high"' ...
```

Default to the configured reasoning effort unless the user explicitly asks for a
different one.

### Selection guidelines

- Use the user's requested model and effort exactly if they specify them.
- Use the configured defaults for normal adversarial review.
- Increase reasoning effort for:
  - architecture critiques
  - security-sensitive reviews
  - subtle bug hunts
  - "what did I miss?" follow-up passes

## How to invoke

### Generating unique output file paths

Always use a unique output path to avoid race conditions from concurrent invocations.
Generate one before each Codex call:

```bash
CODEX_OUT=$(mktemp /tmp/codex-adversary-XXXXXX)
```

Then pass `-o "$CODEX_OUT"` and read the file after Codex finishes.

> **macOS note:** BSD `mktemp` requires the `X`s to be the **last characters** in the
> template. Do not add a file extension (e.g., `.md`) after the `X`s — it will silently
> break randomization.

### 1. Adversarial exec (general critique)

Use `codex exec` with `--sandbox read-only` and `--ephemeral` to get a disposable,
read-only session. Capture the output with `-o` so you can read the response back.

```bash
CODEX_OUT=$(mktemp /tmp/codex-adversary-XXXXXX)
codex exec \
  -c 'model_reasoning_effort="high"' \
  --sandbox read-only \
  --ephemeral \
  -o "$CODEX_OUT" \
  "YOUR PROMPT HERE"
```

Then use the **Read tool** on `$CODEX_OUT` to see the adversary's response.

**Constructing the prompt:** The prompt you send to codex should:

- Clearly state what you want critiqued (paste the relevant code, plan, or idea inline
  or reference specific file paths that codex can read).
- Ask for specific adversarial feedback: flaws, edge cases, security issues, alternative
  approaches, things you might have missed.
- Request structured output (e.g., bullet points, numbered issues) so you can parse the
  feedback easily.

**Example prompt patterns:**

```
Review the following implementation for bugs, edge cases, and design flaws.
Be adversarial — assume something is wrong and find it.
Files: src/apps/pluto/public/entries/create_entry.py

List each issue as:
- **Issue**: description
- **Severity**: high/medium/low
- **Suggestion**: how to fix
```

```
I'm planning to implement X using approach Y. Challenge this decision.
What could go wrong? What alternatives should I consider?
Here is the plan:
<paste plan>
```

### 2. Adversarial code review

Use `codex exec review` to review actual code changes. This is ideal after writing code
and before committing. It supports all exec flags (`-m`, `-o`, `--ephemeral`) plus
review-specific flags (`--uncommitted`, `--base`, `--commit`, `--title`).

```bash
CODEX_OUT=$(mktemp /tmp/codex-review-XXXXXX)

# Review uncommitted changes
codex exec review \
  -c 'model_reasoning_effort="high"' \
  --ephemeral \
  -o "$CODEX_OUT" \
  --uncommitted

# Review changes against a base branch
codex exec review \
  -c 'model_reasoning_effort="high"' \
  --ephemeral \
  -o "$CODEX_OUT" \
  --base main

# Review a specific commit
codex exec review \
  -c 'model_reasoning_effort="high"' \
  --ephemeral \
  -o "$CODEX_OUT" \
  --commit <SHA>

# With custom review instructions
codex exec review \
  -c 'model_reasoning_effort="high"' \
  --ephemeral \
  -o "$CODEX_OUT" \
  --uncommitted \
  "Focus on security vulnerabilities and race conditions"
```

Then use the **Read tool** on `$CODEX_OUT` to process the review output.

### 3. Iterative adversarial loop

For deeper adversarial iterations:

1. **You propose** — write code or a plan.

1. **Codex critiques** — run `codex exec` or `codex exec review` asking for flaws. Save
   the output to a file with `-o`.

1. **You refine** — address the feedback.

1. **Codex re-critiques** — run again, including the previous output as context.
   Reference the file path in your prompt so Codex can read it (it has
   `--sandbox read-only` access to the filesystem):

   ```bash
   CODEX_ROUND2=$(mktemp /tmp/codex-adversary-r2-XXXXXX)
   codex exec \
     --sandbox read-only \
     --ephemeral \
     -o "$CODEX_ROUND2" \
     "I addressed your previous feedback (see $CODEX_PREV for your earlier
     critique). Review the updated implementation and tell me what I still
     missed. Files: <relevant paths>"
   ```

1. **Converge** — repeat until both models agree the solution is sound.

## Important constraints

- **Always use `--sandbox read-only`** for exec unless codex genuinely needs to write
  files (rare for adversarial review).
- **Use `--ephemeral`** to avoid cluttering session history.
- **Capture output** with `-o` to a unique temp file (use `mktemp`) so you can read and
  process the response.
- **Keep prompts focused.** Codex works best with specific, bounded questions rather
  than "review everything."
- **Do not blindly apply codex suggestions.** You are the primary agent. Evaluate each
  suggestion critically — the adversary can be wrong too. Present the findings and your
  assessment to the user.
- **Timeout awareness:** Codex calls can take 30-120+ seconds depending on complexity.
  Use a generous Bash timeout (180000ms for normal reviews, 300000ms for large codebases
  or high-reasoning-effort passes).

## Error handling

- **Timeout:** If Codex times out, retry with a higher Bash timeout or simplify the
  prompt (smaller scope, fewer files).
- **Empty output file:** If the output file is empty or missing after Codex exits, check
  the Bash exit code. Non-zero usually means an API or auth error. Report the error to
  the user rather than retrying blindly.
- **Authentication errors:** If Codex reports auth issues, ask the user to run
  `codex login` interactively.
- **Truncated output:** If the response seems cut off, re-run with a more focused prompt
  or break the review into smaller parts.

## Output handling

After running codex, always:

1. Read the output file using the **Read tool**.
1. Summarize the key findings for the user.
1. Categorize issues by severity if applicable.
1. State whether you agree or disagree with each point and why.
1. Propose concrete next steps based on the combined analysis.

## Additional useful flags

These flags are available on `codex exec` and `codex exec review`:

- `--json` — Print events as JSONL to stdout. Useful for structured parsing when you
  need machine-readable output instead of markdown.
- `--image <FILE>` — Attach image(s) to the prompt. Useful for reviewing UI mockups,
  architecture diagrams, or screenshots.
- `--title <TITLE>` — (review only) Provide a commit/PR title for context.
- `--full-auto` — Sandboxed automatic execution without approval prompts. Useful for
  fully automated review pipelines.
