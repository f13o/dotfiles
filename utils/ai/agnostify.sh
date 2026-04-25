#!/usr/bin/env bash
set -euo pipefail

# agnostify — Consolidate AI agent instruction files into AGENTS.md
#
# Migrates with symlinks so all tools still find their files:
#
#   Root-level:
#     AGENTS.md              → .agents/AGENTS.md (if present)
#     CLAUDE.md              → .agents/AGENTS.md (if present)
#
#   Directory-level:
#     .claude/CLAUDE.md      → .agents/AGENTS.md
#     .codex/instructions.md → .agents/AGENTS.md
#     .claude/skills/         → .agents/skills/
#     .claude/commands/       → .agents/commands/
#
#   Also handles:
#     .agents → .claude symlink (inverts it)
#     .claude → .agents symlink (already correct)
#     Circular symlinks (detected and fixed)
#
# Usage:
#   agnostify.sh [--dry-run] [--global]

DRY_RUN=false
GLOBAL=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --global)  GLOBAL=true ;;
    --help|-h) sed -n '3,/^$/s/^# \?//p' "$0"; exit 0 ;;
    *)         echo "Unknown option: $arg"; exit 1 ;;
  esac
done

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "    [dry-run] $*"
  else
    "$@"
  fi
}

relpath() {
  python3 -c "import os.path; print(os.path.relpath('$1', '$2'))"
}

run_relative_link() {
  local target="$1" link_path="$2"
  local rel
  rel="$(relpath "$target" "$(dirname "$link_path")")"
  run ln -s "$rel" "$link_path"
}

write_content() {
  local path="$1" content="$2"
  if [[ "$DRY_RUN" == true ]]; then
    echo "    [dry-run] write $path"
    return 0
  fi
  printf '%s\n' "$content" > "$path"
}

is_linked_to() {
  local src="$1" dst="$2"
  [[ -L "$src" ]] && \
    [[ "$(realpath "$src" 2>/dev/null)" == "$(realpath "$dst" 2>/dev/null)" ]]
}

is_broken_symlink() {
  [[ -L "$1" ]] && [[ ! -e "$1" ]]
}

is_real_dir() {
  [[ -d "$1" && ! -L "$1" ]]
}

should_link_to_canonical() {
  local tool_file="$1" canonical="$2"
  [[ -e "$tool_file" || -L "$tool_file" || -f "$canonical" ]]
}

move_claude_settings_back() {
  local agents_dir="$1" claude_dir="$2"
  local claude_only

  run mkdir -p "$claude_dir"

  for claude_only in settings.json settings.local.json; do
    [[ -f "$agents_dir/$claude_only" ]] || continue
    echo "  ↗ Moving $claude_only back to .claude/ (Claude-specific)"
    run mv "$agents_dir/$claude_only" "$claude_dir/$claude_only"
  done
}

repair_inverted_agents_files() {
  local agents_dir="$1"
  local agents_file="$agents_dir/AGENTS.md"
  local claude_file="$agents_dir/CLAUDE.md"
  local content

  if [[ -L "$agents_file" && -f "$claude_file" && ! -L "$claude_file" ]]; then
    content="$(cat "$claude_file")"
    run rm "$agents_file"
    write_content "$agents_file" "$content"
    run rm -f "$claude_file"
    return 0
  fi

  if is_broken_symlink "$claude_file"; then
    run rm "$claude_file"
  fi
}

invert_agents_dir_symlink() {
  local agents_dir="$1" claude_dir="$2"

  echo "  ✂ Inverting .agents → .claude directory symlink"
  if [[ "$DRY_RUN" == true ]]; then
    run rm "$agents_dir"
    run mv "$claude_dir" "$agents_dir"
    return 0
  fi

  rm "$agents_dir"
  mv "$claude_dir" "$agents_dir"
  repair_inverted_agents_files "$agents_dir"
  move_claude_settings_back "$agents_dir" "$claude_dir"
}

split_claude_dir_symlink() {
  local agents_dir="$1" claude_dir="$2"

  echo "  ✂ Splitting .claude → .agents whole-dir symlink into separate dirs"
  if [[ "$DRY_RUN" == true ]]; then
    run rm "$claude_dir"
    run mkdir -p "$claude_dir"
    return 0
  fi

  rm "$claude_dir"
  mkdir -p "$claude_dir"
  move_claude_settings_back "$agents_dir" "$claude_dir"
}

fix_directory_symlinks() {
  local agents_dir="$1" claude_dir="$2"

  if [[ -L "$agents_dir" && "$(readlink "$agents_dir")" =~ \.claude ]]; then
    invert_agents_dir_symlink "$agents_dir" "$claude_dir"
    return 0
  fi

  if [[ -L "$claude_dir" && "$(readlink "$claude_dir")" =~ \.agents ]]; then
    split_claude_dir_symlink "$agents_dir" "$claude_dir"
  fi
}

recover_agents_content_from_git() {
  local base="$1" agents_dir="$2"
  local git_content source candidate

  for candidate in \
    ".agents/AGENTS.md" \
    ".claude/CLAUDE.md" \
    "AGENTS.md" \
    "CLAUDE.md"
  do
    if git_content="$(git -C "$base" show "HEAD:$candidate" 2>/dev/null)"; then
      source="HEAD:$candidate"
      echo "  ♻ Recovering AGENTS.md content from git ($source)"
      write_content "$agents_dir/AGENTS.md" "$git_content"
      return 0
    fi
  done

  return 0
}

promote_legacy_agents_claude_file() {
  local agents_dir="$1"
  local agents_file="$agents_dir/AGENTS.md"
  local claude_file="$agents_dir/CLAUDE.md"

  [[ -f "$claude_file" && ! -L "$claude_file" ]] || return 0

  echo "  ↗ Renaming legacy .agents/CLAUDE.md → .agents/AGENTS.md"
  if [[ -e "$agents_file" || -L "$agents_file" ]]; then
    run rm -f "$agents_file"
  fi
  run mv "$claude_file" "$agents_file"
}

cleanup_agents_dir() {
  local base="$1" agents_dir="$2"
  local f

  is_real_dir "$agents_dir" || return 0

  for f in "$agents_dir/AGENTS.md" "$agents_dir/CLAUDE.md"; do
    if is_broken_symlink "$f"; then
      echo "  ✂ Removing broken symlink: $f → $(readlink "$f")"
      run rm "$f"
    fi
  done

  promote_legacy_agents_claude_file "$agents_dir"

  if [[ ! -f "$agents_dir/AGENTS.md" && ! -f "$agents_dir/CLAUDE.md" ]]; then
    recover_agents_content_from_git "$base" "$agents_dir"
  fi

  if [[ -L "$agents_dir/CLAUDE.md" ]]; then
    echo "  ✂ Removing .agents/CLAUDE.md (redundant)"
    run rm "$agents_dir/CLAUDE.md"
  fi
}

migrate_shared_subdir() {
  local agents_dir="$1" claude_dir="$2" subdir="$3"
  local agent_sub="$agents_dir/$subdir"
  local claude_sub="$claude_dir/$subdir"
  local conflicts

  if is_linked_to "$claude_sub" "$agent_sub" 2>/dev/null; then
    echo "  ✓ $subdir/: .claude/$subdir → .agents/$subdir"
    return 0
  fi

  if is_real_dir "$claude_sub" && [[ ! -d "$agent_sub" ]]; then
    echo "  ↗ $subdir/: moving .claude/$subdir → .agents/$subdir"
    run mv "$claude_sub" "$agent_sub"
    run ln -s "../.agents/$subdir" "$claude_sub"
    return 0
  fi

  if [[ ! -e "$claude_sub" && -d "$agent_sub" ]]; then
    echo "  → $subdir/: linking .claude/$subdir → .agents/$subdir"
    run ln -s "../.agents/$subdir" "$claude_sub"
    return 0
  fi

  if ! is_real_dir "$claude_sub" || ! is_real_dir "$agent_sub"; then
    return 0
  fi

  conflicts="$(comm -12 <(ls "$claude_sub" | sort) <(ls "$agent_sub" | sort))"
  if [[ -n "$conflicts" ]]; then
    echo "  ⚠ $subdir/: both .claude/$subdir and .agents/$subdir exist with overlapping entries:"
    echo "    $conflicts"
    echo "    Resolve manually"
    return 1
  fi

  echo "  ↗ $subdir/: merging .claude/$subdir into .agents/$subdir"
  if [[ "$DRY_RUN" == false ]]; then
    cp -a "$claude_sub/"* "$agent_sub/" 2>/dev/null || true
    rm -rf "$claude_sub"
    ln -s "../.agents/$subdir" "$claude_sub"
  else
    echo "    [dry-run] cp -a $claude_sub/* $agent_sub/"
    echo "    [dry-run] rm -rf $claude_sub"
    echo "    [dry-run] ln -s ../.agents/$subdir $claude_sub"
  fi
}

# Link a tool-specific file → canonical AGENTS.md
link_to_canonical() {
  local tool_file="$1"
  local canonical="$2"
  local label="$3"
  local removed_broken_link=false

  # Already correctly linked
  if is_linked_to "$tool_file" "$canonical"; then
    echo "  ✓ $label: $tool_file → $canonical"
    return 0
  fi

  # Broken/circular symlink — remove it
  if is_broken_symlink "$tool_file"; then
    echo "  ✂ $label: removing broken symlink $tool_file"
    run rm "$tool_file"
    removed_broken_link=true
  fi

  # Tool file doesn't exist — symlink if canonical exists
  if [[ "$removed_broken_link" == true || (! -e "$tool_file" && ! -L "$tool_file") ]]; then
    [[ -f "$canonical" ]] || return 0
    echo "  → $label: linking $tool_file → $canonical"
    run mkdir -p "$(dirname "$tool_file")"
    run_relative_link "$canonical" "$tool_file"
    return 0
  fi

  # Symlink to wrong target
  if [[ -L "$tool_file" ]]; then
    echo "  ⚠ $label: $tool_file → $(readlink "$tool_file") (unexpected target)"
    echo "    Resolve manually"
    return 1
  fi

  # Tool file is a real file
  if [[ -f "$tool_file" && ! -L "$tool_file" ]]; then
    if [[ ! -f "$canonical" ]]; then
      echo "  ↗ $label: moving $tool_file → $canonical"
      run mkdir -p "$(dirname "$canonical")"
      run mv "$tool_file" "$canonical"
      run_relative_link "$canonical" "$tool_file"
      return 0
    fi

    if diff -q "$tool_file" "$canonical" &>/dev/null; then
      echo "  ↗ $label: replacing $tool_file with symlink (identical)"
      run rm "$tool_file"
      run_relative_link "$canonical" "$tool_file"
      return 0
    fi

    echo "  ⚠ $label: CONFLICT — $tool_file and $canonical differ"
    echo "    Resolve: diff $tool_file $canonical"
    return 1
  fi

  if [[ -e "$tool_file" ]]; then
    echo "  ⚠ $label: $tool_file exists but is not a regular file"
    echo "    Resolve manually"
    return 1
  fi
}

migrate_project() {
  local base="$1"
  echo "=== Migrating: $base ==="

  local errors=0

  local agents_dir="$base/.agents"
  local claude_dir="$base/.claude"
  fix_directory_symlinks "$agents_dir" "$claude_dir"
  cleanup_agents_dir "$base" "$agents_dir"

  # --- Canonical instruction file lives at .agents/AGENTS.md ---
  local dir_canonical="$agents_dir/AGENTS.md"

  # --- Root-level: preserve existing AGENTS.md / CLAUDE.md only ---
  local root_agents="$base/AGENTS.md"
  local root_claude="$base/CLAUDE.md"
  if [[ -e "$root_agents" || -L "$root_agents" ]]; then
    link_to_canonical "$root_agents" "$dir_canonical" "AGENTS (root)" || ((errors++))
  fi
  if [[ -e "$root_claude" || -L "$root_claude" ]]; then
    link_to_canonical "$root_claude" "$dir_canonical" "Claude Code (root)" || ((errors++))
  fi

  # .claude/CLAUDE.md (only if .claude is a real dir, not symlink to .agents)
  if is_real_dir "$claude_dir"; then
    local claude_file="$claude_dir/CLAUDE.md"
    if should_link_to_canonical "$claude_file" "$dir_canonical"; then
      link_to_canonical "$claude_file" "$dir_canonical" "Claude Code (.claude/)" || ((errors++))
    fi
  fi

  # .codex/instructions.md
  local codex_file="$base/.codex/instructions.md"
  if should_link_to_canonical "$codex_file" "$dir_canonical"; then
    link_to_canonical "$codex_file" "$dir_canonical" "OpenAI Codex" || ((errors++))
  fi

  # --- Shared directories: skills/, commands/ → .agents/ canonical ---
  if is_real_dir "$claude_dir"; then
    for subdir in skills commands; do
      migrate_shared_subdir "$agents_dir" "$claude_dir" "$subdir" || ((errors++))
    done
  fi

  if [[ $errors -gt 0 ]]; then
    echo "  ⚠ $errors conflict(s) need manual resolution"
    return 1
  fi

  echo "  Done"
}

if [[ "$GLOBAL" == true ]]; then
  migrate_project "$HOME"
else
  migrate_project "."
fi
