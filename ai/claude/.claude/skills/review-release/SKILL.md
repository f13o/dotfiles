---
name: review-release
description: Review all commits between main HEAD and latest tag, producing a feature/fix changelog
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Generate a concise changelog between the latest git tag and main HEAD.

# Steps

1. Run `git tag --sort=-version:refname | head -1` to find the latest tag
2. Find the merge-base: `git merge-base <tag> main` -- if empty, the tag may live on a
   different lineage. In that case match the tag's commit message on main using
   `git log main --oneline --grep="<tag commit subject>"` and use that commit as the base.
3. Run `git log <base>..main --oneline` to get commits since the base
4. Produce output per the format below

# Output Format

### Features
- One bullet per distinct feature (group related commits)

### Fixes
- One bullet per fix

### Other
- A single line summarizing all docs/tests/chores/refactors

# Rules

- Maximum 1 sentence per bullet
- No commit hashes
- No filler words
- Omit empty sections
- Aim for 5-15 bullets total; merge aggressively
