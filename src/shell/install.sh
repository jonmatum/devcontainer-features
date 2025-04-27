#!/bin/bash
set -e

# Load feature-utils if available
if [ -f "/usr/local/share/feature-utils.sh" ]; then
  . /usr/local/share/feature-utils.sh
else
  echo "Warning: feature-utils.sh not found. Continuing without it."
fi

echo "> Starting shell environment setup..."

USERNAME="${_REMOTE_USER:-vscode}"

if [ "${USERNAME}" = "root" ]; then
  USER_HOME="/root"
else
  USER_HOME="/home/${USERNAME}"
fi

ZSHRC="${USER_HOME}/.zshrc"
OMZ_DIR="${USER_HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

# Feature options with defaults
: "${installZsh:=true}"
: "${ohMyZsh:=true}"
: "${powerlevel10k:=true}"
: "${autosuggestions:=true}"
: "${syntaxHighlighting:=true}"
: "${opinionated:=false}"
: "${autosuggestHighlight:=fg=8}" # optional: you can move this if you want

detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v apk &>/dev/null; then
    echo "apk"
  else
    echo "unsupported"
  fi
}

install_packages() {
  local packages="$@"
  local pm
  pm=$(detect_package_manager)

  echo "Installing ${packages} using ${pm}..."
  case "${pm}" in
  apt)
    apt-get update -y && apt-get install -y ${packages}
    ;;
  dnf)
    dnf install -y ${packages}
    ;;
  yum)
    yum install -y ${packages}
    ;;
  apk)
    apk add --no-cache ${packages}
    ;;
  *)
    echo "Unsupported package manager."
    exit 1
    ;;
  esac
}

install_zsh() {
  install_packages zsh util-linux-user || true
  echo "Changing default shell to Zsh for user ${USERNAME}..."
  chsh -s "$(command -v zsh)" "${USERNAME}" || true
}

install_oh_my_zsh() {
  if [ ! -d "${OMZ_DIR}" ]; then
    echo "Installing Oh My Zsh..."
    su - "${USERNAME}" -c "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended"
  fi
}

install_powerlevel10k() {
  echo "Installing Powerlevel10k theme..."
  su - "${USERNAME}" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '${ZSH_CUSTOM}/themes/powerlevel10k'"
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "${ZSHRC}" || true

  if [[ "${opinionated}" == "true" ]]; then
    echo "Applying opinionated p10k configuration..."
    cp "$(dirname "$0")/assets/p10k.zsh" "${USER_HOME}/.p10k.zsh"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.p10k.zsh"
    grep -qxF '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' "${ZSHRC}" || echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >>"${ZSHRC}"
  fi
}

install_autosuggestions() {
  echo "Installing zsh-autosuggestions..."
  su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-autosuggestions '${ZSH_CUSTOM}/plugins/zsh-autosuggestions'"
  echo "source ${ZSH_CUSTOM}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >>"${ZSHRC}"
  echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${autosuggestHighlight}'" >>"${ZSHRC}"
}

install_syntax_highlighting() {
  echo "Installing zsh-syntax-highlighting..."
  su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting'"
  echo "source ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>"${ZSHRC}"
}

fix_permissions() {
  echo "Fixing permissions..."
  chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}"
}

# Main logic
install_packages git curl

if [[ "${installZsh}" == "true" ]]; then
  install_zsh
fi

if [[ "${installZsh}" == "true" && "${ohMyZsh}" == "true" ]]; then
  install_oh_my_zsh
fi

if [[ "${powerlevel10k}" == "true" && "${ohMyZsh}" == "true" ]]; then
  install_powerlevel10k
fi

if [[ "${autosuggestions}" == "true" && "${ohMyZsh}" == "true" ]]; then
  install_autosuggestions
fi

if [[ "${syntaxHighlighting}" == "true" && "${ohMyZsh}" == "true" ]]; then
  install_syntax_highlighting
fi

fix_permissions

echo "Shell environment setup completed successfully for ${USERNAME}!"
