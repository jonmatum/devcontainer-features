# DevContainer Sandbox Automation

This document outlines how to use the sandbox workflow powered by `Makefile` and [Copier](https://copier.readthedocs.io) to generate and manage a complete development environment based on DevContainer features.

## Overview

The sandbox system is designed for:

- Rapid prototyping of feature combinations
- Reproducible DevContainer setups
- Simplified developer onboarding

### Key Capabilities

- Interactive CLI for selecting image + features
- Auto-generates `.copier-answers.yml`
- Renders `.sandbox/` workspace via Copier
- Builds and launches the container using the `devcontainer` CLI

## Usage

### 1. Interactive Setup

```bash
make interactive
```

Prompts you to select an image and features, then writes a `.copier-answers.yml` file.

### 2. Generate DevContainer

```bash
make sandbox
```

Renders `.sandbox/` from `.template/` using Copier.
Copies selected features from `src/` into `.sandbox/.devcontainer/features/`.

### 3. Launch Container

```bash
make devcontainer-up
```

Uses the official `devcontainer` CLI to build and start the container.

### 4. Run Commands

```bash
make exec CMD="zsh"
```

Executes commands inside the container workspace. Defaults to `zsh`.

## Files & Structure

```
.
├── .copier-answers.yml         # Saved feature + image selection
├── .template/                  # Copier template (jinja2-powered)
│   └── devcontainer.json.jinja
├── src/                        # Feature source directories
├── .sandbox/                   # Output devcontainer workspace
└── Makefile                    # Entrypoint with all tasks
```

## Make Targets

| Command                | Description                                  |
| ---------------------- | -------------------------------------------- |
| `make help`            | List all available commands                  |
| `make interactive`     | Prompt to choose features + image            |
| `make sandbox`         | Render devcontainer into `.sandbox/`         |
| `make devcontainer-up` | Build and start the container                |
| `make exec`            | Run command inside container (default `zsh`) |
| `make verify`          | Check tool installation in container         |
| `make validate`        | Check `devcontainer.json` schema compliance  |
| `make format`          | Format the `devcontainer.json` via `jq`      |

## DevContainer CLI Requirement

Make sure you have the [DevContainer CLI](https://containers.dev/implementors/cli/) installed (v0.76+):

```bash
npm install -g @devcontainers/cli
```

## Advanced Notes

- If Copier is not installed, the `Makefile` bootstraps it into a local virtualenv
- Answer files are reusable across environments and stored at `.copier-answers.yml`
- Additional validation and formatting tooling is built into the Make targets
