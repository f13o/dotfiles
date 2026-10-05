# Don't forget

## AI instructions

Global instructions for all harnesses live in `ai/AGENTS.md`. Edit that file to
update the shared guidelines.

Install the harness links with:

```sh
stow -d ai -t ~ claude codex
```

- `ai/claude/` contains the Claude Stow package, including its skills.
- `ai/codex/` contains the Codex Stow package.
- `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` resolve to `ai/AGENTS.md`.

## Keymaps

Set Caps lock to Esc


## SSH

```sh
# this-repo/.git/config 

[remote "origin"]
	url = ssh://<ssh_host_alias>/f13o/dotfiles.git
```

```sh
# ~/.ssh/config

Host <ssh_host_alias>
    HostName github.com
    User git
    IdentityFile <path/to/ssh/private/key>
```
