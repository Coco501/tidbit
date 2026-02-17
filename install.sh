#!/usr/bin/env bash

# --- Variables --- #
script_dir="$(cd "$(dirname "$0")" && pwd)"

# CLI Color constants
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
# --- --- #

# --- Helper functions --- #
determine_rc_file() {
    case "$SHELL" in
        */zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        *) # assume bash
            RC_FILE="$HOME/.bashrc"
            ;;
    esac

    if [ ! -f "$RC_FILE" ]; then
        printf "%b\n" "${C_RED}$RC_FILE not found, exiting${C_RESET}"
        exit 1
    fi
}

install_fzf() {
    read -rp "tidbit requires fzf for fuzzy searching, install it? [y/n] " ans
    ans=${ans:-y} # default to y on enter pressed
    ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
    if [ "${ans}" == "y" ] || [ "${ans}" == "yes" ]; then
        if command -v apt >/dev/null 2>&1; then
            sudo apt install -y fzf
        elif command -v brew >/dev/null 2>&1; then
            brew install fzf
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm fzf
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y fzf
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y fzf
        elif command -v zypper >/dev/null 2>&1; then
            sudo zypper install -y fzf
        else
            printf "%b\n" "${C_RED}Could not detect a supported package manager${C_RESET}"
            printf "Please install fzf manually: https://github.com/junegunn/fzf?tab=readme-ov-file#using-git\n"
            exit 1
        fi
    else
        printf "fzf installation denied, exiting\n"
        exit 1
    fi

    printf "\n"
}

select_editor() {
    read -rp "Which editor do you want to use with tidbit? [vim/nvim/nano] " ans
    ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
    case "${ans}" in
        vim)
            EDITOR=vim
            ;;
        nvim|neovim|neo)
            EDITOR=nvim
            ;;
        nano)
            EDITOR=nano
            ;;
        *)
            printf "%b\n" "${C_YELLOW}Option not recognised, defaulting to vim. Can be changed in $RC_FILE ${C_RESET}"
            EDITOR=vim
            ;;
    esac
}

# set_config() {
#     config_file="$script_dir/.tidbitconfig"
#     touch  "$config_file"
#     printf "%b" \
# "\
# editor=$EDITOR\n\
# file_extension=md\n\
# tidbit_dir=$script_dir\n\
# "\
# >> "$config_file"
# }
# --- --- #

# --- Main --- #
main() {
    printf "Using %s as home directory\n" "$HOME"
    determine_rc_file
    printf "Using %s for configuration\n" "$RC_FILE"

    # Check for existence of fzf
    if ! command -v fzf >/dev/null 2>&1; then
        install_fzf
    fi

    read -rp "Allow tidbit to be added to your PATH? [y/n] " ans
    ans=${ans:-y} # default to y on enter pressed
    ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
    if [ "${ans}" == "y" ] || [ "${ans}" == "yes" ]; then
        # Fetch dir of this script
        TIDBIT_DIR="$(cd "$(dirname "$0")" && pwd)"

        if ! grep -Fq "export PATH=\"$TIDBIT_DIR" "$RC_FILE"; then
            printf "# append tidbit executable to path\n" >> "$RC_FILE"
            printf "%b\n" "export PATH=\"$TIDBIT_DIR:\$PATH\"" >> "$RC_FILE"
        else
            printf "%b\n" "${C_YELLOW}'tidbit' was already added to PATH in $RC_FILE ${C_RESET}"
        fi
    else
        printf "Permission to add tidbit to PATH denied, exiting\n"
        exit 1
    fi

    select_editor

    if ! grep -Fq "TIDBIT_EDITOR" "$RC_FILE"; then
        printf "# editor used by tidbit\n" >> "$RC_FILE"
        printf "%b\n" "export TIDBIT_EDITOR=$EDITOR" >> "$RC_FILE"
    else
        printf "%b\n" "${C_YELLOW}$TIDBIT_EDITOR was already set in $RC_FILE ${C_RESET}"
    fi

    # set_config

    printf "%b\n" "${C_GREEN}Installation complete, open a new terminal session and run 'tidbit'${C_RESET}"
}
# --- --- #

# --- Entrypoint --- #
main "$@"

