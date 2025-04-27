#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic tests

# Check that zsh is installed
check "zsh installed" zsh --version

# Check that default shell is set to zsh
check "default shell is zsh" bash -c "[[ \"\$(getent passwd \"\$(whoami)\" | cut -d: -f7)\" == *zsh ]]"

# Check that oh-my-zsh exists
check "oh-my-zsh installed" bash -c "[[ -d \"\$HOME/.oh-my-zsh\" ]]"

# Check that powerlevel10k theme is installed
check "powerlevel10k installed" bash -c "[[ -d \"\$HOME/.oh-my-zsh/custom/themes/powerlevel10k\" ]]"

# Check that autosuggestions plugin is installed
check "autosuggestions installed" bash -c "[[ -d \"\$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions\" ]]"

# Check that syntax-highlighting plugin is installed
check "syntax-highlighting installed" bash -c "[[ -d \"\$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting\" ]]"

# Report
reportResults
