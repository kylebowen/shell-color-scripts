#!/bin/bash

# Variables
REPO_URL="git@github.com:kylebowen/shell-color-scripts.git"
REPO_NAME="shell-color-scripts"
INSTALL_DIR="$HOME/.local/share/colorscripts"
BIN_DIR="$HOME/.bin"
ZSH_COMPLETION_DIR="$HOME/.config/zsh/completion"

# Ensure required packages are installed
function _check_for_required_packages() {
  echo "Checking for required packages..."
  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install it and run this script again."
    exit 1
  fi
}

# Clone colorscripts repository into the current directory
function _clone_repo_to_current_dir() {
  if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning colorscripts repository..."
    git clone "$REPO_URL" "$REPO_NAME"
  else
    echo "Colorscripts repository already exists. Pulling latest changes..."
    git -C "$REPO_NAME" pull
  fi
}

# Create necessary directories
function _create_required_dirs() {
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$BIN_DIR"
  mkdir -p "$ZSH_COMPLETION_DIR"
}

function _prompt_overwrite() {
  local src_file="$1"
  local dest_file="$2"

  if [ -e "$dest_file" ]; then
    read -p "File $dest_file already exists. Overwrite? (y/N): " choice
    case "$choice" in
    y | Y) cp -r "$src_file" "$dest_file" ;;
    *) echo "Skipping $dest_file" ;;
    esac
  else
    cp -r "$src_file" "$dest_file"
  fi
}

# Copy colorscripts to the install directory
function _copy_colorscripts() {
  echo "Copying colorscripts..."
  for file in "$REPO_NAME/colorscripts/"*; do
    _prompt_overwrite "$file" "$INSTALL_DIR/$(basename "$file")"
  done
}

# Copy colorscript.sh to bin directory and make it executable
function _install_colorscript_command() {
  echo "Installing colorscript command..."
  _prompt_overwrite "$REPO_NAME/colorscript.sh" "$BIN_DIR/colorscript"
  chmod +x "$BIN_DIR/colorscript"
}

# Copy zsh completion script
function _install_zsh_completion() {
  echo "Installing zsh completion..."
  _prompt_overwrite "$REPO_NAME/zsh_completion/_colorscript" "$ZSH_COMPLETION_DIR/_colorscript"
}

# Cleanup
function _remove_downloaded_repo() {
  echo "Removing downloaded repo..."
  rm -rf "$REPO_NAME"
}

_check_for_required_packages
_clone_repo_to_current_dir
_create_required_dirs
_copy_colorscripts
_install_colorscript_command
_install_zsh_completion
_remove_downloaded_repo

echo "Installation complete. You can now use 'colorscript'!"
echo "If you haven't already, make sure $BIN_DIR is in your PATH:"
echo "  export PATH=\$HOME/.bin:\$PATH"
