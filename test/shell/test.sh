#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Basic tests

# Check that zsh is installed
check "zsh installed" zsh --version

# Check that oh-my-zsh is NOT installed
check "oh-my-zsh NOT installed" bash -c "[[ ! -d $HOME/.oh-my-zsh ]]"

# Report results
reportResults
