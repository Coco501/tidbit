#!/usr/bin/env bash

C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'

echo -e "Using $HOME as home directory\n"

if [[ ! -f "$HOME"/.bashrc ]]; then
    echo "$HOME/.bashrc not found, exiting"
    exit 1
fi

fzf=$(which fzf)
if [[ -z "$fzf" ]]; then
    read -rp "helpme requires fzf for fuzzy searching, install it? [y/n] " ans
    ans=${ans:-y} # default to y
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        sudo apt install fzf -y
        echo ""
    else
        echo "fzf installation denied, exiting"
        exit 1
    fi
fi

read -rp "Allow helpme to be added to your PATH via $HOME/.bashrc? [y/n] " ans
ans=${ans:-y} # default to y
if [[ "$ans" =~ ^[Yy]$ ]]; then
    HELPME_DIR="$(cd "$(dirname "$0")" && pwd)"

    if ! grep -q "$HELPME_DIR" "$HOME/.bashrc"; then
        echo "# add helpme executable to path" >> "$HOME/.bashrc"
        echo "export PATH=\"$HELPME_DIR:\$PATH\"" >> "$HOME/.bashrc"
    else
        echo -e "${C_YELLOW}'helpme' already added to PATH in $HOME/.bashrc${C_RESET}"
    fi

    echo ""
    read -rp "Which editor do you want to use with helpme? [vim/nvim/nano] " ans
    case "$ans" in 
        vim)
            EDITOR=vim
            ;;
        nvim|neovim)
            EDITOR=nvim
            ;;
        nano)
            EDITOR=nano
            ;;
        *)
            echo "Option not recognised, defaulting to vim. Can be changed in $HOME/.bashrc"
            EDITOR=vim
            ;;
    esac

    if ! grep -q "HELPME_EDITOR" "$HOME/.bashrc"; then
        echo "# editor used by helpme" >> "$HOME/.bashrc"
        echo "export HELPME_EDITOR=$EDITOR" >> "$HOME/.bashrc"
    else
        echo -e "${C_YELLOW}\$HELPME_EDITOR already set in $HOME/.bashrc${C_RESET}"
    fi

    echo -e "\n${C_GREEN}Installation complete, open a new terminal session and run 'helpme'\n${C_RESET}"
else
    echo "Permission to add helpme to PATH denied, exiting"
    exit 1
fi

