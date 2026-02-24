---
name: new-skill
description: Create a new Claude Code skill with proper structure and documentation
disable-model-invocation: true
allowed-tools: Write, Bash(mkdir -p *), AskUserQuestion
argument-hint: [skill-name] [description]
---

Create a new Claude Code skill.

# Argument Validation

## 1. Validate skill name ($0)

CRITICAL: If $0 is empty or not provided:

- Exit with error: "Missing skill name. Usage: /new-skill [skill-name] [description]"
- DO NOT proceed

## 2. Transform skill name

Transform $0 to valid format:

- Convert to lowercase
- Replace spaces and underscores with hyphens
- Remove any characters that are not lowercase letters, numbers, or hyphens
- Truncate to 64 characters if longer

Store the transformed name as the skill name to use.

## 3. Get description

If $1 is empty or not provided:

- Use AskUserQuestion to ask: "What should this skill do?"
- Provide a text input field for the description
- Store the response as the skill description

If $1 is provided:

- Use $1 as the skill description

# Directory Location

ALWAYS ask the user which location to use via AskUserQuestion:

- Option 1: "Global (~/.claude/skills/) - Available across all projects"
- Option 2: "Project-specific (.claude/skills/) - Only for this project"

Based on the response:

- Global: Set base path to `~/.claude/skills/[skill-name]/`
- Project-specific: Set base path to `.claude/skills/[skill-name]/`

# Skill Creation Process

## 1. Create the skill directory

Use Bash to create: `mkdir -p [base-path]`

## 2. Generate SKILL.md

Create the skill file at `[base-path]/SKILL.md` with:

**Frontmatter** (minimum required):

```yaml
---
name: [skill-name]
description: [skill-description]
disable-model-invocation: true
---
```

**Content section**:

```markdown
[Skill-description]

# Steps

1. [Add appropriate steps based on the description]
2. [Keep steps clear and actionable]

# Completion

[Define what success looks like]
```

Note: Generate appropriate steps and completion criteria based on the skill description. Keep
the content focused and under 200 lines for initial creation.

# Verification

After creating the file:

1. Use Read to verify the file exists at `[base-path]/SKILL.md`
2. Check that the frontmatter contains valid YAML with at minimum: name and description
   fields
3. If verification fails, report the error and exit
4. If verification succeeds, report:

   ```
   Skill created successfully!
   Location: [full-path]
   Test with: /[skill-name]
   ```

5. Exit (do not attempt to invoke or test the skill)

# Reference Documentation

The following sections provide reference information for creating skills. DO NOT include
this documentation in the generated SKILL.md. Use this information to guide your creation of
appropriate frontmatter and content.

## Frontmatter Fields

```yaml
---
name: skill-name
description: Clear one-sentence description of what this skill does
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Grep
argument-hint: [arg-name]
model: sonnet
context: inline
agent: general-purpose
---
```

### Field Guidelines

- `name`: lowercase, hyphens only, max 64 chars (becomes `/skill-name` command)
- `description`: Critical for auto-invocation. Describe what it does and when to use it.
- `disable-model-invocation`: Set to `true` for workflows with side effects (deploy,
  commit, etc.)
- `user-invocable`: Set to `false` to hide from `/` menu (for background knowledge)
- `allowed-tools`: Comma-separated list of tools allowed without permission
- `argument-hint`: Shows in autocomplete, e.g. `[issue-number]` or `[filename] [format]`
- `context`: Use `fork` to run in isolated subagent
- `agent`: Which subagent type when context is `fork` (Explore, Plan, general-purpose)

## Content Structure

After the frontmatter, write clear instructions:

1. State the purpose clearly
2. List the steps to follow
3. Include examples if helpful
4. Reference supporting files if needed
5. Keep under 500 lines (use separate files for detailed docs)

## String Substitutions

Use these in your content:

- `$ARGUMENTS` - all arguments passed
- `$0`, `$1`, `$2` - individual arguments by index
- `${CLAUDE_SESSION_ID}` - current session ID

## Common Patterns

### Manual Task Workflow (Deploy, Commit, etc.)

```yaml
---
name: deploy
description: Deploy application to production
disable-model-invocation: true
allowed-tools: Bash(npm *), Bash(git *)
---

Deploy to production:

1. Run tests
2. Build application
3. Push to deployment target
4. Verify deployment
```

### Knowledge Base (Coding Standards, Conventions)

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---

When writing API endpoints:

- Use RESTful conventions
- Return consistent error formats
- Include request validation
```

### Research/Analysis (With Subagent)

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
allowed-tools: Glob, Grep, Read
---

Research $ARGUMENTS:

1. Find relevant files
2. Analyze code
3. Summarize findings
```

### Parameterized Task

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
argument-hint: [issue-number]
---

Fix GitHub issue $0:

1. Read issue description
2. Implement fix
3. Write tests
4. Create commit
```

## Supporting Files

Keep SKILL.md focused by using separate files:

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── reference.md       # Detailed API docs
├── examples.md        # Usage examples
└── scripts/           # Helper scripts
```

Reference them from SKILL.md:

```markdown
For detailed API docs, see [reference.md](reference.md)
```

## Design Principles

1. Keep SKILL.md under 500 lines
2. Write clear, specific descriptions for auto-invocation
3. Use `disable-model-invocation: true` for workflows with side effects
4. Grant minimal tool permissions via `allowed-tools`
5. Use arguments for variable inputs
6. Keep instructions focused and actionable
