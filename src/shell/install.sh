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
: "${TIMEZONE:=UTC}"
: "${INSTALLZSH:=true}"
: "${OHMYZSH:=true}"
: "${NERDFONT:=true}"
: "${POWERLEVEL10K:=true}"
: "${AUTOSUGGESTIONS:=true}"
: "${SYNTAXHIGHLIGHTING:=true}"
: "${OPINIONATED:=false}"
: "${AUTOSUGGESTHIGHLIGHT:=fg=8}"
: "${ZSHRCURL:=}"
: "${P10KURL:=}"
: "${POSTINSTALLSCRIPTURL:=}"

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

install_nerd_font() {
  local font_name="Meslo"
  local font_version="v3.0.2"
  local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/${font_name}.zip"
  local install_dir="${USER_HOME}/.local/share/fonts"

  echo "Installing ${font_name} Nerd Font v3..."

  install_package_if_missing curl
  install_package_if_missing unzip
  install_package_if_missing fc-cache || install_package_if_missing fontconfig

  mkdir -p "$install_dir"
  curl -fLo "/tmp/${font_name}.zip" --retry 3 --retry-delay 2 --location "$download_url"
  unzip -o "/tmp/${font_name}.zip" -d "$install_dir"
  fc-cache -f "$install_dir"

  chown -R "${USERNAME}:${USERNAME}" "$install_dir"

  echo "${font_name} installed to $install_dir"
}

install_autosuggestions() {
  local plugin_dir="${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  if [ ! -d "${plugin_dir}" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    su - "${USERNAME}" -c "git clone https://github.com/zsh-users/zsh-autosuggestions '${plugin_dir}'"
  fi
  grep -qxF "source ${plugin_dir}/zsh-autosuggestions.zsh" "${ZSHRC}" || echo "source ${plugin_dir}/zsh-autosuggestions.zsh" >>"${ZSHRC}"
  grep -qxF "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${AUTOSUGGESTHIGHLIGHT}'" "${ZSHRC}" || echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='${AUTOSUGGESTHIGHLIGHT}'" >>"${ZSHRC}"
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
  echo "Applying .zshrc and .p10k.zsh configuration..."

  local default_zshrc_url="https://gist.githubusercontent.com/jonmatum/55a5ff475dbb3c5854d5ddd40dc5961d/raw/ccdd446307f915627691e58a935af8246cfd4aeb/.zshrc"
  local default_p10k_url="https://gist.githubusercontent.com/jonmatum/c0b7c317f281b03bb857e425fe23f9d4/raw/031c6099a176989cc0ecbc24f097c7d547195e08/.p10k.zsh"

  local final_zshrc_url="${ZSHRCURL:-$default_zshrc_url}"
  local final_p10k_url="${P10KURL:-$default_p10k_url}"

  if curl -fsSL "$final_zshrc_url" -o "${USER_HOME}/.zshrc"; then
    echo ".zshrc downloaded from $final_zshrc_url"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.zshrc"
  else
    echo "Failed to download .zshrc from $final_zshrc_url"
  fi

  if curl -fsSL "$final_p10k_url" -o "${USER_HOME}/.p10k.zsh"; then
    echo ".p10k.zsh downloaded from $final_p10k_url"
    chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.p10k.zsh"
  else
    echo "Failed to download .p10k.zsh from $final_p10k_url"
  fi

  # Disable Powerlevel10k wizard only if not already set
  if ! grep -q 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' "${USER_HOME}/.zshrc"; then
    echo "Disabling Powerlevel10k config wizard"
    echo "POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" >>"${USER_HOME}/.zshrc"
  fi
}

run_post_install_script() {
  if [ -n "$POSTINSTALLSCRIPTURL" ]; then
    echo "> Running custom post-install script from $POSTINSTALLSCRIPTURL"
    curl -fsSL "$POSTINSTALLSCRIPTURL" | bash || echo "Warning: Failed to execute post-install script."
  else
    echo "> No post-install script URL provided. Skipping."
  fi
}

print_summary() {
  echo
  echo -e "${BOLD}> Setup Summary:${NC}"
  echo

  summary_check() {
    local label="$1"
    local cmd="$2"
    local version_cmd="$3"
    printf "  %-22s" "$label"
    if command -v "$cmd" >/dev/null 2>&1; then
      echo -en "${GREEN}✔ Installed${NC}  "
      { eval "$version_cmd" 2>/dev/null || echo "Version unknown"; } | head -n 1 || true
    else
      echo -e "${RED}✘ Not found${NC}"
    fi
  }

  [[ "$INSTALLZSH" == "true" ]] && summary_check "Zsh" zsh "zsh --version"
  [[ "$OHMYZSH" == "true" ]] && summary_check "Oh My Zsh" zsh "grep -q oh-my-zsh ~/.zshrc && echo 'Enabled'"
  [[ "$POWERLEVEL10K" == "true" ]] && summary_check "Powerlevel10k" zsh "grep -q powerlevel10k ~/.zshrc && echo 'Enabled'"
  [[ "$NERDFONT" == "true" ]] && summary_check "Nerd Font" fc-cache "fc-list | grep -i meslo | head -n 1"
  [[ "$AUTOSUGGESTIONS" == "true" ]] && summary_check "Autosuggestions" zsh "grep -q zsh-autosuggestions ~/.zshrc && echo 'Enabled'"
  [[ "$SYNTAXHIGHLIGHTING" == "true" ]] && summary_check "Syntax Highlighting" zsh "grep -q zsh-syntax-highlighting ~/.zshrc && echo 'Enabled'"
  [[ "$OPINIONATED" == "true" ]] && summary_check "Opinionated Config" curl "echo 'Custom .zshrc and .p10k.zsh used'"

  echo
  echo -e "${BOLD}✔ Shell environment setup complete for ${USERNAME}!${NC}"
}

configure_timezone() {
  if [ -n "$TIMEZONE" ]; then
    echo "Setting timezone to $TIMEZONE"

    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime || {
      echo "Failed to link timezone. Check if $TIMEZONE is valid."
      return
    }
    echo "$TIMEZONE" >/etc/timezone 2>/dev/null || true

    # Debian-specific handling for tzdata reconfiguration
    if command -v dpkg-reconfigure &>/dev/null; then
      install_package_if_missing tzdata
      DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata
    fi
  fi
}

# --- MAIN ---

ensure_common_dependencies

configure_timezone

if [[ "${INSTALLZSH}" == "true" ]]; then
  install_zsh
fi

if [[ "${INSTALLZSH}" == "true" && "${OHMYZSH}" == "true" ]]; then
  install_oh_my_zsh
fi

if [[ "${POWERLEVEL10K}" == "true" && "${OHMYZSH}" == "true" ]]; then
  install_powerlevel10k
fi

if [[ "${NERDFONT}" == "true" ]]; then
  install_nerd_font
fi

if [[ "${AUTOSUGGESTIONS}" == "true" && "${OHMYZSH}" == "true" ]]; then
  install_autosuggestions
fi

if [[ "${SYNTAXHIGHLIGHTING}" == "true" && "${OHMYZSH}" == "true" ]]; then
  install_syntax_highlighting
fi

if [[ "${OPINIONATED}" == "true" ]]; then
  apply_opinionated_files
fi

fix_permissions

run_post_install_script

print_summary
