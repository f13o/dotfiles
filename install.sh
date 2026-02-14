#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dev       Install dev tools (colima, docker, mise, pnpm, uv, 1password-cli)"
  echo "  --core      Install core utilities (fd, fzf, ripgrep, etc.)"
  echo "  --ui        Install UI tools (kitty, neovim, yazi, fonts)"
  echo "  --all       Install all groups (default if no flags provided)"
  echo "  --help      Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 --dev --core    Install dev and core tools only"
  echo "  $0 --all           Install everything"
  exit 0
}

install_dev=false
install_core=false
install_ui=false

if [ $# -eq 0 ]; then
  install_dev=true
  install_core=true
  install_ui=true
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --dev)
      install_dev=true
      shift
      ;;
    --core)
      install_core=true
      shift
      ;;
    --ui)
      install_ui=true
      shift
      ;;
    --all)
      install_dev=true
      install_core=true
      install_ui=true
      shift
      ;;
    --help|-h)
      show_usage
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      ;;
  esac
done

if [ "$install_dev" = true ]; then
  echo "Installing dev tools..."
  brew install \
    colima \
    docker \
    docker-compose \
    docker-buildx \
    mise \
    pnpm \
    uv \
    1password-cli

  mkdir -p ~/.docker/cli-plugins/ && ln -sf $(which docker-compose) ~/.docker/cli-plugins/
fi

if [ "$install_core" = true ]; then
  echo "Installing core utilities..."
  brew install \
    fd \
    fzf \
    gnupg \
    jq \
    ripgrep \
    stow \
    watch
fi

if [ "$install_ui" = true ]; then
  echo "Installing UI tools..."
  brew install \
    kitty \
    font-fira-code-nerd-font \
    neovim \
    yazi \
    zoxide \
    ffmpeg \
    resvg \
    imagemagick \
    sevenzip \
    poppler \
    deno ## needed for Peek markdown preview
fi

echo "Installation complete!"
