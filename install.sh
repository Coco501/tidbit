#!/usr/bin/env bash

# --- Variables --- #
script_dir="$(cd "$(dirname "$0")" && pwd)"
config_file="$script_dir/.tidbitconfig"

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
    read -rp "tidbit requires fzf for fuzzy searching, install it? [Y/n] " ans
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

select_file_extension() {
    read -rp "Which file extension do you want to use for tidbit? [default is md] " ans

    # strip all leading dots
    while [[ $ans == .* ]]; do
        ans=${ans#.}
    done

    file_extension=${ans:-md}
}

select_alias() {
    read -rp "Would you like a short alias for tidbit? [leave blank to skip] " ans
    alias_name="$ans"
}

set_config_var() {
    key=$1
    value=$2

    if grep -q "^${key}=" "$config_file"; then
        if sed --version >/dev/null 2>&1; then
            # GNU sed (Linux)
            sed -i "s|^${key}=.*|${key}=${value}|" "$config_file"
        else
            # BSD sed (macOS)
            sed -i '' "s|^${key}=.*|${key}=${value}|" "$config_file"
        fi
    else
        printf "%s=%s\n" "$key" "$value" >> "$config_file"
    fi
}

install_completion() {
    local completion_file="$script_dir/completions/tidbit-completion.$1"
    local source_line=". \"$completion_file\""

    if ! grep -Fq "$completion_file" "$RC_FILE"; then
        printf "# tidbit shell completion\n" >> "$RC_FILE"
        printf "%s\n" "$source_line" >> "$RC_FILE"
    else
        printf "%b\n" "${C_YELLOW}tidbit completion was already added to $RC_FILE ${C_RESET}"
    fi
}

update_config() {
    touch  "$config_file"

    set_config_var "editor" "$EDITOR"
    set_config_var "file_extension" "$file_extension"
}
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

    read -rp "Allow tidbit to be added to your PATH? [Y/n] " ans
    ans=${ans:-y} # default to y on enter pressed
    ans=$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')
    if [ "${ans}" == "y" ] || [ "${ans}" == "yes" ]; then
        if ! grep -Fq "export PATH=\"$script_dir" "$RC_FILE"; then
            printf "\n# append tidbit executable to path\n" >> "$RC_FILE"
            printf "%b\n" "export PATH=\"$script_dir:\$PATH\"" >> "$RC_FILE"
        else
            printf "%b\n" "${C_YELLOW}'tidbit' was already added to PATH in $RC_FILE ${C_RESET}"
        fi
    else
        printf "Permission to add tidbit to PATH denied, exiting\n"
        exit 1
    fi

    select_editor
    select_file_extension
    select_alias
    update_config

    case "$SHELL" in
        */zsh) install_completion zsh ;;
        *)     install_completion bash ;;
    esac

    if [ -n "$alias_name" ]; then
        if ! grep -Fq "alias $alias_name=" "$RC_FILE"; then
            printf "alias %s=tidbit\n" "$alias_name" >> "$RC_FILE"
            case "$SHELL" in
                */zsh) printf "compdef _tidbit %s\n" "$alias_name" >> "$RC_FILE" ;;
                *)     printf "complete -F _tidbit_complete %s\n" "$alias_name" >> "$RC_FILE" ;;
            esac
        fi
    fi

    printf "%b\n" "${C_GREEN}Installation complete, open a new terminal session and run 'tidbit'${C_RESET}"
}
# --- --- #

# --- Entrypoint --- #
main "$@"

