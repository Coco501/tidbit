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

select_editor() {
    echo ""
    read -rp "Which editor do you want to use with tidbit? [vim/nvim/nano] " ans
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
    echo -e "Using $HOME as home directory\n"

    if [[ ! -f "$HOME"/.bashrc ]]; then
        echo "$HOME/.bashrc not found, exiting"
        exit 1
    fi

    fzf=$(which fzf)
    if [[ -z "$fzf" ]]; then
        read -rp "tidbit requires fzf for fuzzy searching, install it? [y/n] " ans
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

    read -rp "Allow tidbit to be added to your PATH? [y/n] " ans
    ans=${ans:-y} # default to y on enter pressed
    if [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]; then
        # Fetch dir of this script
        TIDBIT_DIR="$(cd "$(dirname "$0")" && pwd)"

        if ! grep -q "$TIDBIT_DIR" "$HOME/.bashrc"; then
            echo "# append tidbit executable to path" >> "$HOME/.bashrc"
            echo "export PATH=\"$TIDBIT_DIR:\$PATH\"" >> "$HOME/.bashrc"
        else
            echo -e "${C_YELLOW}'tidbit' was already added to PATH in $HOME/.bashrc${C_RESET}"
        fi

        select_editor

        if ! grep -q "TIDBIT_EDITOR" "$HOME/.bashrc"; then
            echo "# editor used by tidbit" >> "$HOME/.bashrc"
            echo "export TIDBIT_EDITOR=$EDITOR" >> "$HOME/.bashrc"
        else
            echo -e "${C_YELLOW}\$TIDBIT_EDITOR was already set in $HOME/.bashrc${C_RESET}"
        fi

        # set_config

        echo -e "\n${C_GREEN}Installation complete, open a new terminal session and run 'tidbit'\n${C_RESET}"
    else
        echo "Permission to add tidbit to PATH denied, exiting"
        exit 1
    fi
}
# --- --- #

# --- Entrypoint --- #
main "$@"

