# Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core apps
sh install.sh

stow -t ~/.config config/

stow -t ~ git claude zsh

