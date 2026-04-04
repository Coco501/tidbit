#!/usr/bin/env bats
# Tests for install.sh helper functions.
# Requires bats-core: https://github.com/bats-core/bats-core

INSTALL_SCRIPT="$BATS_TEST_DIRNAME/../install.sh"

setup() {
    TIDBIT_DIR="$(mktemp -d)"
    RC_FILE="$TIDBIT_DIR/.bashrc"
    touch "$RC_FILE"

    config_file="$TIDBIT_DIR/.tidbitconfig"
    script_dir="$TIDBIT_DIR"

    # Source install.sh functions without triggering main
    # shellcheck source=../install.sh
    source "$INSTALL_SCRIPT"

    # Override config_file and script_dir to point at temp dir
    config_file="$TIDBIT_DIR/.tidbitconfig"
    script_dir="$TIDBIT_DIR"
}

teardown() {
    rm -rf "$TIDBIT_DIR"
}

# --- set_config_var --- #

@test "set_config_var writes a new key to config" {
    touch "$config_file"
    set_config_var "editor" "nvim"
    grep -q "^editor=nvim$" "$config_file"
}

@test "set_config_var updates an existing key" {
    printf "editor=vim\n" > "$config_file"
    set_config_var "editor" "nvim"
    grep -q "^editor=nvim$" "$config_file"
    # Should not contain old value
    ! grep -q "^editor=vim$" "$config_file"
}

@test "set_config_var does not duplicate an existing key" {
    printf "editor=vim\n" > "$config_file"
    set_config_var "editor" "nvim"
    [ "$(grep -c "^editor=" "$config_file")" -eq 1 ]
}

@test "set_config_var writes multiple distinct keys" {
    touch "$config_file"
    set_config_var "editor" "nvim"
    set_config_var "file_extension" "txt"
    grep -q "^editor=nvim$" "$config_file"
    grep -q "^file_extension=txt$" "$config_file"
}

# --- select_file_extension --- #

@test "select_file_extension strips a single leading dot" {
    file_extension=""
    ans=".md"
    while [[ $ans == .* ]]; do ans="${ans#.}"; done
    file_extension="${ans:-md}"
    [ "$file_extension" = "md" ]
}

@test "select_file_extension strips multiple leading dots" {
    ans="...md"
    while [[ $ans == .* ]]; do ans="${ans#.}"; done
    file_extension="${ans:-md}"
    [ "$file_extension" = "md" ]
}

@test "select_file_extension defaults to md on empty input" {
    ans=""
    while [[ $ans == .* ]]; do ans="${ans#.}"; done
    file_extension="${ans:-md}"
    [ "$file_extension" = "md" ]
}

# --- install_completion --- #

@test "install_completion adds source line to RC file" {
    mkdir -p "$TIDBIT_DIR/completions"
    touch "$TIDBIT_DIR/completions/tidbit-completion.bash"
    install_completion bash
    grep -q "tidbit-completion.bash" "$RC_FILE"
}

@test "install_completion is idempotent" {
    mkdir -p "$TIDBIT_DIR/completions"
    touch "$TIDBIT_DIR/completions/tidbit-completion.bash"
    install_completion bash
    install_completion bash
    [ "$(grep -c "tidbit-completion.bash" "$RC_FILE")" -eq 1 ]
}

# --- alias writing (in main, tested via state) --- #

@test "alias and completion registration are written to RC after completion source" {
    mkdir -p "$TIDBIT_DIR/completions"
    touch "$TIDBIT_DIR/completions/tidbit-completion.bash"
    install_completion bash

    alias_name="td"
    printf "\nalias %s=tidbit\n" "$alias_name" >> "$RC_FILE"
    printf "complete -F _tidbit_complete %s\n" "$alias_name" >> "$RC_FILE"

    # completion source must appear before the alias
    source_line=$(grep -n "tidbit-completion" "$RC_FILE" | cut -d: -f1)
    alias_line=$(grep -n "alias td=" "$RC_FILE" | cut -d: -f1)
    [ "$source_line" -lt "$alias_line" ]
}

@test "alias is not written twice on repeated install" {
    alias_name="td"
    if ! grep -Fq "alias $alias_name=" "$RC_FILE"; then
        printf "\nalias %s=tidbit\n" "$alias_name" >> "$RC_FILE"
    fi
    if ! grep -Fq "alias $alias_name=" "$RC_FILE"; then
        printf "\nalias %s=tidbit\n" "$alias_name" >> "$RC_FILE"
    fi
    [ "$(grep -c "alias td=" "$RC_FILE")" -eq 1 ]
}
