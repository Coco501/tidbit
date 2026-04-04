#!/usr/bin/env bats
# Tests for bash completion function.
# Requires bats-core: https://github.com/bats-core/bats-core

setup() {
    TIDBIT_DIR="$(mktemp -d)"

    # Fake tidbit on PATH so command -v tidbit resolves to TIDBIT_DIR
    printf '#!/usr/bin/env bash\n' > "$TIDBIT_DIR/tidbit"
    chmod +x "$TIDBIT_DIR/tidbit"
    export PATH="$TIDBIT_DIR:$PATH"

    printf "file_extension=md\n" > "$TIDBIT_DIR/.tidbitconfig"

    mkdir -p "$TIDBIT_DIR/subjects/git"
    touch "$TIDBIT_DIR/subjects/git/tidbit.md"
    touch "$TIDBIT_DIR/subjects/git/commands.md"

    mkdir -p "$TIDBIT_DIR/subjects/vim"
    touch "$TIDBIT_DIR/subjects/vim/tidbit.md"
    touch "$TIDBIT_DIR/subjects/vim/motions.md"

    # Source the completion file to load _tidbit_complete
    # shellcheck source=../completions/tidbit-completion.bash
    source "$BATS_TEST_DIRNAME/../completions/tidbit-completion.bash"
}

teardown() {
    rm -rf "$TIDBIT_DIR"
}

# Simulates a tab-press at position $1 with words "$@"
simulate_completion() {
    local cword=$1; shift
    COMP_WORDS=("$@")
    COMP_CWORD=$cword
    COMPREPLY=()
    _tidbit_complete
}

# --- First argument completions --- #

@test "first argument includes all subject directories" {
    simulate_completion 1 tidbit ""
    [[ "${COMPREPLY[*]}" == *"git"* ]]
    [[ "${COMPREPLY[*]}" == *"vim"* ]]
}

@test "first argument includes unique commands" {
    simulate_completion 1 tidbit ""
    [[ "${COMPREPLY[*]}" == *"help"* ]]
    [[ "${COMPREPLY[*]}" == *"version"* ]]
    [[ "${COMPREPLY[*]}" == *"config"* ]]
}

@test "first argument filters by prefix" {
    simulate_completion 1 tidbit "gi"
    [[ "${COMPREPLY[*]}" == *"git"* ]]
    [[ "${COMPREPLY[*]}" != *"vim"* ]]
}

@test "new subject directory appears in completions without re-sourcing" {
    mkdir -p "$TIDBIT_DIR/subjects/python"
    simulate_completion 1 tidbit ""
    [[ "${COMPREPLY[*]}" == *"python"* ]]
}

# --- Second argument completions --- #

@test "second argument lists files under the given subject without extension" {
    simulate_completion 2 tidbit git ""
    [[ "${COMPREPLY[*]}" == *"tidbit"* ]]
    [[ "${COMPREPLY[*]}" == *"commands"* ]]
}

@test "second argument filters by prefix" {
    simulate_completion 2 tidbit git "co"
    [[ "${COMPREPLY[*]}" == *"commands"* ]]
    [[ "${COMPREPLY[*]}" != *"tidbit"* ]]
}

@test "second argument returns empty for a non-existent subject" {
    simulate_completion 2 tidbit nonexistent ""
    [ "${#COMPREPLY[@]}" -eq 0 ]
}

@test "second argument strips file extension from completions" {
    simulate_completion 2 tidbit git ""
    # Should contain 'commands', not 'commands.md'
    [[ "${COMPREPLY[*]}" == *"commands"* ]]
    [[ "${COMPREPLY[*]}" != *"commands.md"* ]]
}

@test "new file in subject appears in completions without re-sourcing" {
    touch "$TIDBIT_DIR/subjects/git/newfile.md"
    simulate_completion 2 tidbit git ""
    [[ "${COMPREPLY[*]}" == *"newfile"* ]]
}
