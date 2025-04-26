# DevContainer Features

Reusable, production-ready DevContainer features for cloud, full-stack, DevOps, and infrastructure development environments.  
Modular, portable, and compatible with Amazon Linux, Ubuntu, and Debian-based systems.

> **Compatible with:** Amazon Linux • Ubuntu • Debian

## Features Included

- Shell environment (Zsh, Oh My Zsh, Powerlevel10k, syntax highlighting, autosuggestions)
- AWS CLI v2
- Terraform with tfswitch
- OpenTofu (Terraform fork)
- Python via pyenv (with optional pipenv)
- Node.js via nvm
- Pre-commit setup

Each tool is packaged as an independent, composable DevContainer Feature.

## Usage

You can directly reference features from this repository using the `gh:` prefix in your `devcontainer.json`:

```json
"features": {
  "gh:jonmatum/devcontainer-features/features/python:1.0.0": {
    "version": "3.11.9",
    "pipenv": true
  },
  "gh:jonmatum/devcontainer-features/features/aws:1.0.0": {},
  "gh:jonmatum/devcontainer-features/features/terraform:1.0.0": {},
  "gh:jonmatum/devcontainer-features/features/shell:1.0.0": {}
}
```

Replace the feature ID and version according to what you need.

## Structure

```text
features/
  shell/
    feature.json
    install.sh
  aws/
    feature.json
    install.sh
  python/
    feature.json
    install.sh
  terraform/
    feature.json
    install.sh
  opentofu/
    feature.json
    install.sh
  node/
    feature.json
    install.sh
```

## Roadmap

- Add additional features for Kubernetes tooling
- Publish metadata to DevContainer Feature Registry (when available)
- Improve auto-detection of CPU architecture
- Add CI validation workflows

## License

Licensed under the [MIT License](LICENSE).

---

> echo 'Pura Vida & Happy Coding!";