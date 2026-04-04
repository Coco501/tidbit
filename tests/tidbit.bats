#!/usr/bin/env bats
# Tests for the main tidbit script.
# Requires bats-core: https://github.com/bats-core/bats-core

load helpers/common

setup() { setup_tidbit_env; }
teardown() { teardown_tidbit_env; }

# --- Help --- #

@test "tidbit help prints usage" {
    run "$TIDBIT_DIR/tidbit" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: tidbit"* ]]
}

@test "tidbit --help prints usage" {
    run "$TIDBIT_DIR/tidbit" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: tidbit"* ]]
}

@test "tidbit -h prints usage" {
    run "$TIDBIT_DIR/tidbit" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: tidbit"* ]]
}

@test "help flag is case insensitive" {
    run "$TIDBIT_DIR/tidbit" HELP
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: tidbit"* ]]
}

# --- Version --- #

@test "tidbit version prints version number" {
    run "$TIDBIT_DIR/tidbit" version
    [ "$status" -eq 0 ]
    [[ "$output" == *"tidbit version"* ]]
}

@test "tidbit --version prints version number" {
    run "$TIDBIT_DIR/tidbit" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"tidbit version"* ]]
}

@test "tidbit -v prints version number" {
    run "$TIDBIT_DIR/tidbit" -v
    [ "$status" -eq 0 ]
    [[ "$output" == *"tidbit version"* ]]
}

@test "version flag is case insensitive" {
    run "$TIDBIT_DIR/tidbit" VERSION
    [ "$status" -eq 0 ]
    [[ "$output" == *"tidbit version"* ]]
}

# --- Argument validation --- #

@test "three or more arguments exits with error" {
    run "$TIDBIT_DIR/tidbit" git commands extra
    [ "$status" -eq 1 ]
    [[ "$output" == *"Too many arguments"* ]]
}

# --- File resolution --- #

@test "subject only opens subject/tidbit.<ext>" {
    run "$TIDBIT_DIR/tidbit" git
    [ "$status" -eq 0 ]
    [[ "$output" == *"subjects/git/tidbit.md" ]]
}

@test "subject and file opens the correct file" {
    run "$TIDBIT_DIR/tidbit" git commands
    [ "$status" -eq 0 ]
    [[ "$output" == *"subjects/git/commands.md" ]]
}

@test "file argument with correct extension is stripped before resolving" {
    run "$TIDBIT_DIR/tidbit" git commands.md
    [ "$status" -eq 0 ]
    [[ "$output" == *"subjects/git/commands.md" ]]
}

@test "file with multiple dots only strips the file_extension suffix" {
    touch "$TIDBIT_DIR/subjects/git/note.backup.md"
    run "$TIDBIT_DIR/tidbit" git note.backup.md
    [ "$status" -eq 0 ]
    [[ "$output" == *"subjects/git/note.backup.md" ]]
}

@test "file with a different extension is not stripped" {
    run bash -c "echo n | \"$TIDBIT_DIR/tidbit\" git commands.txt"
    [ "$status" -eq 0 ]
    # If extension were stripped, it would find commands.md and the editor would print its path
    [[ "$output" != *"commands.md"* ]]
}

# --- File not found --- #

@test "missing file prompts to create, answering no does not create it" {
    run bash -c "echo n | \"$TIDBIT_DIR/tidbit\" git nonexistent"
    [ "$status" -eq 0 ]
    [ ! -f "$TIDBIT_DIR/subjects/git/nonexistent.md" ]
}

@test "missing file prompts to create, answering yes creates and opens it" {
    run bash -c "echo y | \"$TIDBIT_DIR/tidbit\" git newfile"
    [ "$status" -eq 0 ]
    [ -f "$TIDBIT_DIR/subjects/git/newfile.md" ]
}

@test "missing file with missing subject directory is created on yes" {
    run bash -c "echo y | \"$TIDBIT_DIR/tidbit\" newsubject newfile"
    [ "$status" -eq 0 ]
    [ -f "$TIDBIT_DIR/subjects/newsubject/newfile.md" ]
}

@test "default answer to create prompt is yes" {
    run bash -c "echo '' | \"$TIDBIT_DIR/tidbit\" git newfile"
    [ "$status" -eq 0 ]
    [ -f "$TIDBIT_DIR/subjects/git/newfile.md" ]
}
