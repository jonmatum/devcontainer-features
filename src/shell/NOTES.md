# Devcontainer Shell Feature

This repository provides a fully-automated shell environment for DevContainers using:

- Zsh with Oh My Zsh, Powerlevel10k, and plugins
- Meslo Nerd Font v3 installer
- Cross-platform timezone support
- Customizable opinionated dotfiles
- Post-install script hook
- Smart feature summary at the end

## Features Included

### Shell Environment Options

| Option                 | Type    | Default | Description                                                                             |
| ---------------------- | ------- | ------- | --------------------------------------------------------------------------------------- |
| `installZsh`           | boolean | `true`  | Install Zsh and set it as the default shell.                                            |
| `ohMyZsh`              | boolean | `true`  | Install [Oh My Zsh](https://ohmyz.sh).                                                  |
| `powerlevel10k`        | boolean | `true`  | Install [Powerlevel10k](https://github.com/romkatv/powerlevel10k).                      |
| `autosuggestions`      | boolean | `true`  | Enable [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions).         |
| `syntaxHighlighting`   | boolean | `true`  | Enable [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting). |
| `nerdFont`             | boolean | `true`  | Install Meslo Nerd Font v3.0.2 locally in user fonts.                                   |
| `timezone`             | string  | `UTC`   | Set system timezone (e.g. `Europe/Paris`).                                              |
| `opinionated`          | boolean | `false` | Apply curated `.zshrc` and `.p10k.zsh` configuration.                                   |
| `zshrcUrl`             | string  | `""`    | Custom `.zshrc` URL (overrides opinionated default).                                    |
| `p10kUrl`              | string  | `""`    | Custom `.p10k.zsh` URL (overrides opinionated default).                                 |
| `postInstallScriptUrl` | string  | `""`    | Optional URL to a bash script to execute after setup.                                   |

## Meslo Nerd Font Installer

Installs [Meslo Nerd Font v3.0.2](https://github.com/ryanoasis/nerd-fonts) into `~/.local/share/fonts`.

- Supports Debian, Alpine, and Amazon Linux
- Verifies and installs required tools: `curl`, `unzip`, `fontconfig`
- Runs `fc-cache` to refresh fonts

## Timezone Configuration

If `timezone` is set:

- Symlinks `/etc/localtime` to the correct zoneinfo file
- Writes to `/etc/timezone`
- Installs `tzdata` if necessary (Debian-based systems)

Example:

```json
"timezone": "America/Costa_Rica"
```

## Opinionated Dotfiles

If `opinionated=true`, the following behavior is applied:

- `.zshrc` and `.p10k.zsh` are downloaded from curated Gist URLs
- These can be overridden with `zshrcUrl` and `p10kUrl`
- Adds `POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true` to prevent interactive wizard

## Post-Install Script Support

A custom shell script can be executed automatically:

```json
"postInstallScriptUrl": "https://example.com/my-extra-setup.sh"
```

This script will be downloaded and executed after the rest of the feature setup.

## Final Setup Summary

At the end of setup, a status table will be printed summarizing all enabled tools:

```
> Setup Summary:

  Zsh                 ✔ Installed  zsh 5.9
  Oh My Zsh           ✔ Installed  Enabled
  Powerlevel10k       ✔ Installed  Enabled
  Nerd Font           ✔ Installed  MesloLGS NF
  Autosuggestions     ✔ Installed  Enabled
  Syntax Highlighting ✔ Installed  Enabled
  Opinionated Config  ✔ Installed  Custom .zshrc and .p10k.zsh used

✔ Shell environment setup complete for user
```

---

> For sandbox and template automation via Make + Copier, see [`SANDBOX.md`](../../SANDBOX.md).
