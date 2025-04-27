#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Example: you could check that Zsh is still installed, but Oh-My-Zsh isn't if disabled
check "zsh installed" zsh --version

# If oh-my-zsh was turned off in the scenario, you could add:
check "oh-my-zsh NOT installed" bash -c "[[ ! -d \"\$HOME/.oh-my-zsh\" ]]"

reportResults
