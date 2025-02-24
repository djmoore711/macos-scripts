#!/bin/bash

# ------------------------------------------------------------------------------
# Script Name: install_homebrew_and_packages.sh
#
# Description: 
#   This script checks if Homebrew is installed on your macOS system.
#   If not, it installs Homebrew, sets up the PATH, and then installs a list
#   of specified packages as either casks or formulas.
#
# Author: Darrell Moore Jr (DJ)
# Date Created: 2025-02-18
# Last Modified: 2025-02-21
# Version: 1.1
#
# Usage: 
#   Run this script from the terminal:
#       ./install_homebrew_and_packages.sh
#
# Requirements:
#   - macOS with Bash installed.
#   - Internet connection.
#
# License: MIT License
#
# Notes:
#   - Make sure that your dash characters are standard hyphens.
#   - Adjust the package list to your own needs.
#   - Error logs are written out to the directory from where the script is run.
#   - The script will append to the log file if it already exists.
# ------------------------------------------------------------------------------
# Change Log
# 2025/02/21: Added error logging for failed package installations
# 2025/02/20: Initial Release
#
# VARIABLES   ------------------------------------------------------------------

# List of packages to install
packages=(
    "python"
    "git"
    "wget"
    "coreutils"
    "tree"
    "docker"
    "pyenv"
    "zsh-completion"
    "docker-compose"
    "ack"
    "midnight-commander"
    "pyenv-virtualenv"
    "thefuck"
    "gnutls"
    "highlight"
    "ssh-copy-id"
    "packer"
    "doxygen"
    "pv"
    "socat"
    "zsh-syntax-highlighting"
    "speedtest-cli"
    "spellcheck"
    "rename"
    "cowsay"
    "ripgrep"
    "logstash"
    "ncdu"
    "moreutils"
    "curl"
    "cmatrix"
    "trash"
    "bitwarden"
    "windsurf"
    "visual-studio-code"
    "readdle-spark"
    "vivaldi"
    "chatgpt"
    "zen-browser"
    "sublime-text"
    "warp"
    "postman"
    "stats"
    "discord"
    "zoom"
    "notion"
    "podman-desktop"
    "virtualbox"
    "telegram"
    "signal"
    "whiskey"
    "grammarly-desktop"
    "nightfall"
    "neohtop"
    "mactracker"
    "trex"
    "poe"
    "gog-galaxy"
    "rocket"
    "nomachine"
    "beeper"
    "rectangle"
    "browserosaurus"
    "macwhisper"
    "dash"
    "headlamp"
    "font-monaspace-nerd-font"
    "quicklook-json"
    "todoist"
    "hyper"
    "keyclu"
    "coteditor"
    "mac-mouse-fix"
    "unnaturalscrollwheels"
    "nordvpn"
    "tailscale"
    "ollama"
    "tor-browser"
    "balenaetcher"
    "google-drive"
    "brave-browser"
    "transnomino"
    "only-switch"
    "sketchybar"
    "raycast"
)

# FUNCTIONS --------------------------------------------------------------------

# Function to install Homebrew
# Uses official Homebrew install script from GitHub
function install_brew {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to set up Homebrew in PATH
# Different paths for Intel vs Apple Silicon Macs
function setup_path {
    # Append to .zprofile (create if doesn't exist)
    if ! echo >> "$HOME/.zprofile"; then
        echo -e "\nFailed to write to .zprofile\n"
        return 1
    fi
    
    # Determine correct Homebrew path based on CPU architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PATH="/opt/homebrew/bin/brew"    # Path for Apple Silicon
    else
        BREW_PATH="/usr/local/bin/brew"       # Path for Intel
    fi
    
    # Add Homebrew to PATH and apply changes
    echo "eval \"\$(${BREW_PATH} shellenv)\"" >> "$HOME/.zprofile"
    eval "$(${BREW_PATH} shellenv)"
    export PATH
    echo -e "\nPATH has been set to include Homebrew.\n"
}

# Function

function error_logging {
    local package_name="$1"
    local file_name="new_mac_setup_log_file.txt"
    formatted_date=$(date "+%Y-%m-%d %H:%M:%S - $package_name")

    # Check if the file exists
    if [ ! -f "$file_name" ]; then
        echo -e "\nFile does not exist. Creating it...\n"
        touch "$file_name" # Create the file
        echo "This is the log of errors that occurred during " \ 
        "the script execution." > "$file_name"
    else
        echo -e "\nFile exists. Will append to it.\n"
    fi

    # Append content to the file
    echo "$formatted_date" >> "$file_name"
    echo -e "\nFailed to install cask: $package_name\n"
}

# Function to install all packages from the packages array
# Detects whether each package should be installed as a cask or formula
function install_packages {
    local success=true
    for package in "${packages[@]}"; do
        # Check if package is available as a cask
        if brew info --cask "$package" &> /dev/null; then
            echo -e "\nInstalling cask: $package\n"
            brew install --cask "$package"
            if [[ $? -ne 0 ]]; then
                echo "Failed to install cask: $package"
                error_logging "$package" # Log the package that did not install 
                success=false
            fi
        # If not a cask, check if it's available as a formula
        elif brew info "$package" &> /dev/null; then
            echo "Installing formula: $package"
            brew install "$package"
            if [[ $? -ne 0 ]]; then
                echo -e "\nFailed to install formula: $package\n"
                success=false
            fi
        else
            echo -e "\nPackage $package not found in Homebrew repositories.\n"
            success=false
        fi
    done
    
    # Return overall success/failure status
    if [[ $success = true ]]; then
        return 0
    else
        return 1
    fi
}

# MAIN ------------------------------------------------------------------------

# Track if this is a new Homebrew installation
new_install="false"

echo "Starting Homebrew and package setup..."

# Check if Homebrew is already installed
echo "Checking if Homebrew is installed..."
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew is already installed."
else
    echo "Homebrew is not installed. Installing Homebrew..."
    install_brew
    new_install="true"
    if [[ $? -ne 0 ]]; then
        echo "Failed to install Homebrew. Please check your internet connection and try again."
        exit 1
    fi
    setup_path
    if [[ $? -ne 0 ]]; then
        echo "Failed to set up PATH. Please check your internet connection and try again."
        exit 1
    fi
fi

# Update Homebrew if it's not a new installation
echo "Updating Homebrew..."
if [[ $new_install = "true" ]]; then    # Using string comparison instead of -eq
    echo "Homebrew was just installed. Skipping update."
else
    if ! brew update; then
        echo "Failed to update Homebrew."
        exit 1
    fi
fi

# Install all specified packages
echo -e "\nInstalling all packages...\n"
install_packages

echo -e "Script completed.\n"