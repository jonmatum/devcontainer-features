#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic tests

# Check that zsh is installed
check "execute command" bash -c "zsh --version"

# Optional: Check if zsh is the default shell (only if you care)
# check "default shell is zsh" bash -c "[[ $(getent passwd $(whoami) | cut -d: -f7) == *zsh ]]"

# Report results
reportResults
