# Don't forget

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
