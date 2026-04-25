#!/bin/zsh
SCRIPT_DIR="${0:A:h}"

swiftc -O "$SCRIPT_DIR/input-source.swift" -o "$SCRIPT_DIR/input-source" -framework Carbon
mkdir -p ~/.local/bin
ln -sf "$SCRIPT_DIR/is" ~/.local/bin/is

