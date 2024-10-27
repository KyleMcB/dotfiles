#!/bin/bash

# setup.sh
# A script to set up the development environment using Homebrew and Fish shell.
# Author: Your Name
# Date: YYYY-MM-DD

# Function to print formatted messages
print_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# Function to install Homebrew
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    print_message "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Detect Homebrew installation path and add to PATH
    if [[ "$(uname -m)" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.bash_profile
    else
      eval "$(/usr/local/bin/brew shellenv)"
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.bash_profile
    fi

    print_message "Homebrew installation complete."
  else
    print_message "Homebrew is already installed."
  fi
}

# Function to add Homebrew tap
add_homebrew_tap() {
  TAP_NAME="nikitabobko/tap"
  if brew tap | grep -q "^${TAP_NAME}$"; then
    print_message "Homebrew tap '${TAP_NAME}' is already added."
  else
    print_message "Adding Homebrew tap '${TAP_NAME}'..."
    brew tap nikitabobko/tap
    print_message "Tap '${TAP_NAME}' added successfully."
  fi
}

# Function to install Homebrew packages
install_homebrew_packages() {
  FORMULAE=(neovim fd ripgrep fish ag stow nmap neovide lazygit zellij eza tldr)
  CASKS=(anki nikitabobko/tap/aerospace) # neovide is a cask but installs better as a formulae

  print_message "Installing Homebrew formulae..."
  for formula in "${FORMULAE[@]}"; do
    if brew list --formula | grep -q "^${formula}\$"; then
      echo "Formula '${formula}' is already installed."
    else
      brew install "$formula"
      echo "Installed '${formula}'."
    fi
  done
  print_message "Homebrew formulae installation complete."

  print_message "Installing Homebrew casks..."
  for cask in "${CASKS[@]}"; do
    if brew list --cask | grep -q "^${cask}\$"; then
      echo "Cask '${cask}' is already installed."
    else
      brew install --cask "$cask"
      echo "Installed '${cask}'."
    fi
  done

set_fish_as_default_shell() {
  FISH_PATH="$(which fish)"

  if ! grep -Fxq "$FISH_PATH" /etc/shells; then
    print_message "Adding Fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi

  if [ "$SHELL" != "$FISH_PATH" ]; then
    print_message "Changing default shell to Fish..."
    chsh -s "$FISH_PATH"
    print_message "Default shell changed to Fish. Please restart your terminal."
  else
    print_message "Fish is already the default shell."
  fi
}

use_stow() {
  print_message "linking via stow"
  stow ./*/ 
}

# Main function to orchestrate setup
main() {
  install_homebrew
  add_homebrew_tap
  install_homebrew_packages
  set_fish_as_default_shell
#  use_stow
#  

  print_message "System setup complete! please choose a branch and use stow to install config files"
}

# Execute main function
main
