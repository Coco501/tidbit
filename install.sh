#!/usr/bin/env bash

# CLI Color constants
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'

# --- Helper functions --- #

# Install fzf with package manager detection
install_fzf() {
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
        return 1
    fi
}

# Prompt user to select their editor of choice
select_editor() {
    echo ""
    read -rp "Which editor do you want to use with helpme? [vim/nvim/nano] " ans
    case "${ans,,}" in 
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
            echo -e "${C_YELLOW}Option not recognised, defaulting to vim. Can be changed in $HOME/.bashrc${C_RESET}"
            EDITOR=vim
            ;;
    esac
}
# --- --- #

# --- Main --- #
main() {
    echo -e "Using $HOME as home directory\n"

    if [[ ! -f "$HOME"/.bashrc ]]; then
        echo "$HOME/.bashrc not found, exiting"
        exit 1
    fi

    fzf=$(which fzf)
    if [[ -z "$fzf" ]]; then
        read -rp "helpme requires fzf for fuzzy searching, install it? [y/n] " ans
        ans=${ans:-y} # default to y on enter pressed
        if [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]; then
            if ! install_fzf; then
                echo -e "${C_RED}Could not detect a supported package manager${C_RESET}"
                echo "Please install fzf manually: https://github.com/junegunn/fzf?tab=readme-ov-file#using-git"
                exit 1
            fi
            echo ""
        else
            echo "fzf installation denied, exiting"
            exit 1
        fi
    fi

    read -rp "Allow helpme to be added to your PATH via $HOME/.bashrc? [y/n] " ans
    ans=${ans:-y} # default to y on enter pressed
    if [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]; then
        # Fetch dir of this script
        HELPME_DIR="$(cd "$(dirname "$0")" && pwd)"

        if ! grep -q "$HELPME_DIR" "$HOME/.bashrc"; then
            echo "# append helpme executable to path" >> "$HOME/.bashrc"
            echo "export PATH=\"$HELPME_DIR:\$PATH\"" >> "$HOME/.bashrc"
        else
            echo -e "${C_YELLOW}'helpme' was already dded to PATH in $HOME/.bashrc${C_RESET}"
        fi

        select_editor

        if ! grep -q "HELPME_EDITOR" "$HOME/.bashrc"; then
            echo "# editor used by helpme" >> "$HOME/.bashrc"
            echo "export HELPME_EDITOR=$EDITOR" >> "$HOME/.bashrc"
        else
            echo -e "${C_YELLOW}\$HELPME_EDITOR was already set in $HOME/.bashrc${C_RESET}"
        fi

        echo -e "\n${C_GREEN}Installation complete, open a new terminal session and run 'helpme'\n${C_RESET}"
    else
        echo "Permission to add helpme to PATH denied, exiting"
        exit 1
    fi
}
# --- --- #

# --- Entrypoint --- #
main "$@"

