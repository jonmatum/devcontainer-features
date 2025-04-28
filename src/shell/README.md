
# Shell Setup (shell)

Configurable shell setup with optional Zsh, Oh My Zsh, Powerlevel10k, autosuggestions, and syntax highlighting.

## Example Usage

```json
"features": {
    "ghcr.io/jonmatum/devcontainer-features/shell:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installZsh | Install Zsh and set it as the default shell. | boolean | true |
| ohMyZsh | Install the Oh My Zsh framework. | boolean | true |
| powerlevel10k | Install the Powerlevel10k theme for Zsh. | boolean | true |
| autosuggestions | Enable the zsh-autosuggestions plugin. | boolean | true |
| syntaxHighlighting | Enable the zsh-syntax-highlighting plugin. | boolean | true |
| opinionated | Apply custom opinionated configuration. | boolean | false |
| zshrcUrl | URL to a custom .zshrc file. | string | - |
| p10kUrl | URL to a custom .p10k.zsh file. | string | - |
| postInstallScriptUrl | Optional URL to a bash script to execute at the end of the setup. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/jonmatum/devcontainer-features/blob/main/src/shell/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
