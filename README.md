# DevContainer Features

Reusable, production-ready DevContainer Features for cloud, full-stack, DevOps, and infrastructure development environments.  
Modular, portable, and compatible with Amazon Linux, Ubuntu, and Debian-based systems.

> **Compatible with:** Amazon Linux • Ubuntu • Debian

## Features Included

- **Shell Environment** (Zsh, Oh My Zsh, Powerlevel10k, syntax highlighting, autosuggestions)
- **AWS CLI v2**
- **Terraform** (with tfswitch)
- **OpenTofu** (Terraform fork)
- **Python** (via pyenv, with optional pipenv)
- **Node.js** (via nvm)
- **Pre-commit** (Hooks Setup)

Each tool is packaged as an independent, composable DevContainer Feature.

## Usage

You can reference features from this repository directly using the `gh:` prefix in your `devcontainer.json`:

```json
{
    "features": {
        "gh:jonmatum/devcontainer-features/python:1.0.0": {
            "version": "3.11.9",
            "pipenv": true
        },
        "gh:jonmatum/devcontainer-features/aws:1.0.0": {},
        "gh:jonmatum/devcontainer-features/terraform:1.0.0": {},
        "gh:jonmatum/devcontainer-features/shell:1.0.0": {}
    }
}
```

Replace the feature ID and version according to your requirements.

## Structure

Each Feature is organized under the `src/` folder following the DevContainer [Feature distribution specification](https://containers.dev/implementors/features-distribution/).

```text
src/
  shell/
    devcontainer-feature.json
    install.sh
  aws/
    devcontainer-feature.json
    install.sh
  python/
    devcontainer-feature.json
    install.sh
  terraform/
    devcontainer-feature.json
    install.sh
  opentofu/
    devcontainer-feature.json
    install.sh
  node/
    devcontainer-feature.json
    install.sh
```

## Versioning

Each Feature is individually versioned using the `version` attribute in its `devcontainer-feature.json`.  
Versioning follows [Semantic Versioning (SemVer)](https://semver.org/).

Example snippet from a Feature:

```json
{
  "id": "shell",
  "version": "1.0.0",
  ...
}
```

Releases are automated via GitHub Actions using [release-please](https://github.com/googleapis/release-please), generating a changelog and GitHub Release per update.

## Publishing

Features are automatically published to **GitHub Container Registry (GHCR)** following the [DevContainer Feature distribution spec](https://containers.dev/implementors/features-distribution/).

- Each Feature is published individually under:  
  `ghcr.io/jonmatum/devcontainer-features/<feature>:<version>`
- A **feature collection metadata package** is also published:  
  `ghcr.io/jonmatum/devcontainer-features`

> **Important:** After publishing, Features must be manually marked as **Public** in the GitHub Package settings to be discoverable and usable.

**Example URLs:**
- Feature: `https://github.com/users/jonmatum/packages/container/devcontainer-features/shell`
- Collection: `https://github.com/users/jonmatum/packages/container/devcontainer-features`

## License

Licensed under the [MIT License](LICENSE).

---

> echo "Pura Vida & Happy Coding!"; 
