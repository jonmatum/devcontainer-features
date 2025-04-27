#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Check that zsh is installed
check "execute command" bash -c "zsh --version"

# Report results
reportResults
