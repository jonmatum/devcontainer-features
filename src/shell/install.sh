#!/bin/bash
set -e

echo "> Starting shell environment setup..."

USERNAME="${_REMOTE_USER:-root}"

if id "$USERNAME" &>/dev/null; then
  echo "Using user: $USERNAME"
else
  echo "Warning: User '$USERNAME' not found. Falling back to root."
  USERNAME="root"
fi

# Resolve home directory safely
if [ "${USERNAME}" = "root" ]; then
  USER_HOME="/root"
elif [ -d "/home/${USERNAME}" ]; then
  USER_HOME="/home/${USERNAME}"
else
  echo "Warning: User home for '${USERNAME}' not found. Defaulting to /root."
  USER_HOME="/root"
fi

ZSHRC="${USER_HOME}/.zshrc"
OMZ_DIR="${USER_HOME}/.oh-my-zsh"
ZSH_CUSTOM="${OMZ_DIR}/custom"

# Feature options
: "${installZsh:=true}"
: "${ohMyZsh:=true}"
: "${powerlevel10k:=true}"
: "${autosuggestions:=true}"
: "${syntaxHighlighting:=true}"
: "${opinionated:=false}"
: "${autosuggestHighlight:=fg=8}"
: "${zshrcUrl:=}"
: "${p10kUrl:=}"
: "${postInstallScriptUrl:=}"

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

install_package_if_missing() {
  local package="$1"
  if ! command -v "$package" &>/dev/null; then
    echo "Installing missing package: $package"
    local pm
    pm=$(detect_package_manager)
    case "${pm}" in
    apt)
      apt-get update -y && apt-get install -y --no-install-recommends "$package"
      ;;
    dnf)
      dnf install -y --allowerasing "$package"
      ;;
    yum)
      yum install -y "$package"
      ;;
    apk)
      apk add --no-cache "$package"
      ;;
    *)
      echo "Unsupported package manager."
      exit 1
      ;;
    esac
  fi
}

ensure_common_dependencies() {
  echo "Ensuring common system dependencies..."
  for pkg in curl git tar bash ca-certificates; do
    install_package_if_missing "$pkg"
  done
}

install_zsh() {
  if ! command -v zsh &>/dev/null; then
    install_package_if_missing zsh
    # Special case: Amazon Linux needs util-linux-user for chsh
    local pm
    pm=$(detect_package_manager)
    if [[ "$pm" == "dnf" || "$pm" == "yum" ]]; then
      install_package_if_missing util-linux-user || echo "Skipping util-linux-user: not needed."
    fi
  fi

  echo "Changing default shell to Zsh for user ${USERNAME}"
  chsh -s "$(command -v zsh)" "${USERNAME}" || echo "Warning: Failed to change shell, continuing..."
}

install_oh_my_zsh() {
  if [ ! -d "${OMZ_DIR}" ]; then
    echo "Installing Oh My Zsh for ${USERNAME}..."
    # Set correct HOME manually so installer puts files in the right place
    HOME="${USER_HOME}" su - "${USERNAME}" -c "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" --unattended"

    # Ensure correct ownership
    chown -R "${USERNAME}:${USERNAME}" "${OMZ_DIR}"
  else
    echo "Oh My Zsh already installed, skipping."
  fi

  # Make sure .zshrc points to correct OMZ install
  if [ ! -f "${ZSHRC}" ]; then
    echo "Creating missing .zshrc at ${ZSHRC}"
    echo 'export ZSH="$HOME/.oh-my-zsh"' >"${ZSHRC}"
    echo 'ZSH_THEME="robbyrussell"' >>"${ZSHRC}"
    chown "${USERNAME}:${USERNAME}" "${ZSHRC}"
  else
    grep -qxF 'export ZSH="$HOME/.oh-my-zsh"' "${ZSHRC}" || echo 'export ZSH="$HOME/.oh-my-zsh"' >>"${ZSHRC}"
    grep -qxF 'ZSH_THEME="robbyrussell"' "${ZSHRC}" || echo 'ZSH_THEME="robbyrussell"' >>"${ZSHRC}"
  fi
}

install_powerlevel10k() {
  local theme_dir="${ZSH_CUSTOM}/themes/powerlevel10k"

  if [ ! -d "${theme_dir}" ]; then
    echo "Installing Powerlevel10k..."
    su - "${USERNAME}" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '${theme_dir}'"
  else
    echo "Powerlevel10k already installed, skipping."
  fi

  # Ensure theme activation
  if grep -q '^ZSH_THEME=' "${ZSHRC}"; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "${ZSHRC}"
  else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >>"${ZSHRC}"
  fi
}

install_autosuggestions() {
  local plugin_dir="${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  if [ ! -d "${plugin_dir}" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-autosuggestions '${plugin_dir}'"
  fi
  grep -qxF "source ${plugin_dir}/zsh-autosuggestions.zsh" "${ZSHRC}" || echo "source ${plugin_dir}/zsh-autosuggestions.zsh" >>"${ZSHRC}"
  grep -qxF "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${autosuggestHighlight}'" "${ZSHRC}" || echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${autosuggestHighlight}'" >>"${ZSHRC}"
}

install_syntax_highlighting() {
  local plugin_dir="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  if [ ! -d "${plugin_dir}" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '${plugin_dir}'"
  fi
  grep -qxF "source ${plugin_dir}/zsh-syntax-highlighting.zsh" "${ZSHRC}" || echo "source ${plugin_dir}/zsh-syntax-highlighting.zsh" >>"${ZSHRC}"
}

fix_permissions() {
  echo "Fixing permissions..."
  chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}"
}

apply_opinionated_files() {
  echo "> Applying opinionated config files..."

  # Download custom .zshrc if provided
  if [ -n "$zshrcUrl" ]; then
    echo "Downloading custom .zshrc from $zshrcUrl"
    curl -fsSL "$zshrcUrl" -o "${USER_HOME}/.zshrc"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.zshrc"
  else
    echo "No custom .zshrc URL provided. Skipping."
    # Always disable the Powerlevel10k wizard
    echo "POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" >>"${USER_HOME}/.zshrc"
  fi

  # Download custom .p10k.zsh if provided
  if [ -n "$p10kUrl" ]; then
    echo "Downloading custom .p10k.zsh from $p10kUrl"
    curl -fsSL "$p10kUrl" -o "${USER_HOME}/.p10k.zsh"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.p10k.zsh"
  else
    echo "No custom .p10k.zsh URL provided. Skipping."
  fi
}

run_post_install_script() {
  if [ -n "$postInstallScriptUrl" ]; then
    echo "> Running custom post-install script from $postInstallScriptUrl"
    curl -fsSL "$postInstallScriptUrl" | bash || echo "Warning: Failed to execute post-install script."
  else
    echo "> No post-install script URL provided. Skipping."
  fi
}

# --- MAIN ---

ensure_common_dependencies

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

if [[ "${opinionated}" == "true" ]]; then
  apply_opinionated_files
fi

fix_permissions

run_post_install_script

echo "Shell environment setup completed successfully for ${USERNAME}!"
