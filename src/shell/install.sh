#!/bin/bash
set -e

# Import devcontainer feature utils if available
source /usr/local/share/feature-utils.sh || true

USERNAME="${_REMOTE_USER:-vscode}"
USER_HOME="/home/${USERNAME}"
ZSHRC="${USER_HOME}/.zshrc"
OMZ_DIR="${USER_HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

# Feature options with defaults
: "${INSTALLZSH:=true}"
: "${OHMYZSH:=true}"
: "${POWERLEVEL10K:=true}"
: "${AUTOSUGGESTIONS:=true}"
: "${SYNTAXHIGHLIGHTING:=true}"
: "${AUTOSUGGESTHIGHLIGHT:=fg=8}"
: "${OPINIONATED:=false}"

detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  else
    echo "unsupported"
  fi
}

install_git_if_needed() {
  if ! command -v git &>/dev/null; then
    echo "Git not found. Installing git..."
    local package_manager
    package_manager=$(detect_package_manager)
    case "${package_manager}" in
    apt)
      apt-get update && apt-get install -y git
      ;;
    dnf)
      dnf install -y git
      ;;
    yum)
      yum install -y git
      ;;
    *)
      echo "Unsupported package manager. Cannot install git automatically."
      exit 1
      ;;
    esac
  fi
}

install_zsh() {
  local package_manager
  package_manager=$(detect_package_manager)

  echo "Installing Zsh using ${package_manager}..."
  case "${package_manager}" in
  apt)
    apt-get update && apt-get install -y zsh
    ;;
  dnf)
    dnf install -y zsh util-linux-user
    ;;
  yum)
    yum install -y zsh util-linux-user
    ;;
  *)
    echo "Unsupported package manager. Cannot install Zsh automatically."
    exit 1
    ;;
  esac

  echo "Changing default shell to Zsh for user ${USERNAME}"
  chsh -s "$(command -v zsh)" "${USERNAME}"
}

install_oh_my_zsh() {
  if [ ! -d "${OMZ_DIR}" ]; then
    echo "Installing Oh My Zsh..."
    su - "${USERNAME}" -c "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended"
  fi

  if [ ! -f "${ZSHRC}" ]; then
    echo "Creating empty .zshrc at ${ZSHRC}"
    touch "${ZSHRC}"
    chown "${USERNAME}:${USERNAME}" "${ZSHRC}"
  fi

  grep -qxF 'export ZSH="$HOME/.oh-my-zsh"' "${ZSHRC}" || echo 'export ZSH="$HOME/.oh-my-zsh"' >>"${ZSHRC}"
  grep -qxF 'ZSH_THEME="robbyrussell"' "${ZSHRC}" || echo 'ZSH_THEME="robbyrussell"' >>"${ZSHRC}"
}

install_powerlevel10k() {
  local THEME_DIR="${ZSH_CUSTOM}/themes/powerlevel10k"
  if [ ! -d "${THEME_DIR}" ]; then
    echo "Installing Powerlevel10k theme..."
    su - "${USERNAME}" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '${THEME_DIR}'"
  fi
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "${ZSHRC}" || true

  if [[ "${OPINIONATED}" == "true" ]]; then
    echo "Applying opinionated Powerlevel10k configuration..."
    cp "$(dirname "$0")/assets/p10k.zsh" "${USER_HOME}/.p10k.zsh"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.p10k.zsh"
    grep -qxF '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' "${ZSHRC}" || echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >>"${ZSHRC}"
  fi
}

install_autosuggestions() {
  local PLUGIN_DIR="${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  if [ ! -d "${PLUGIN_DIR}" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-autosuggestions '${PLUGIN_DIR}'"
  fi
  grep -qxF "source ${PLUGIN_DIR}/zsh-autosuggestions.zsh" "${ZSHRC}" || echo "source ${PLUGIN_DIR}/zsh-autosuggestions.zsh" >>"${ZSHRC}"
  grep -qxF "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${AUTOSUGGESTHIGHLIGHT}'" "${ZSHRC}" || echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${AUTOSUGGESTHIGHLIGHT}'" >>"${ZSHRC}"
}

install_syntax_highlighting() {
  local PLUGIN_DIR="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  if [ ! -d "${PLUGIN_DIR}" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '${PLUGIN_DIR}'"
  fi
  grep -qxF "source ${PLUGIN_DIR}/zsh-syntax-highlighting.zsh" "${ZSHRC}" || echo "source ${PLUGIN_DIR}/zsh-syntax-highlighting.zsh" >>"${ZSHRC}"
}

finalize_permissions() {
  echo "Adjusting ownership for user ${USERNAME}..."
  chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}"
}

# --- Main ---
echo "Starting shell environment setup..."

install_git_if_needed

if [[ "${INSTALLZSH}" == "true" ]]; then
  install_zsh
fi

if [[ "${OHMYZSH}" == "true" ]]; then
  install_oh_my_zsh
fi

if [[ "${POWERLEVEL10K}" == "true" ]]; then
  install_powerlevel10k
fi

if [[ "${AUTOSUGGESTIONS}" == "true" ]]; then
  install_autosuggestions
fi

if [[ "${SYNTAXHIGHLIGHTING}" == "true" ]]; then
  install_syntax_highlighting
fi

finalize_permissions

echo "Shell environment setup completed successfully for user ${USERNAME}."
