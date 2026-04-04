# Shared setup for all test suites.
# Creates an isolated tidbit environment in a temp directory.

setup_tidbit_env() {
    TIDBIT_DIR="$(mktemp -d)"

    # Minimal config — editor records the file it was called with
    cat > "$TIDBIT_DIR/.tidbitconfig" << 'EOF'
editor=/fake_editor
file_extension=md
EOF

    # Fake editor: prints the filepath it receives so tests can assert on it
    cat > "$TIDBIT_DIR/fake_editor" << 'EOF'
#!/usr/bin/env bash
echo "$1"
EOF
    chmod +x "$TIDBIT_DIR/fake_editor"
    sed -i "s|/fake_editor|$TIDBIT_DIR/fake_editor|" "$TIDBIT_DIR/.tidbitconfig"

    # Copy tidbit script so script_dir resolves to TIDBIT_DIR
    cp "$BATS_TEST_DIRNAME/../tidbit" "$TIDBIT_DIR/tidbit"
    chmod +x "$TIDBIT_DIR/tidbit"

    # Seed subjects
    mkdir -p "$TIDBIT_DIR/subjects/git"
    touch "$TIDBIT_DIR/subjects/git/tidbit.md"
    touch "$TIDBIT_DIR/subjects/git/commands.md"

    mkdir -p "$TIDBIT_DIR/subjects/vim"
    touch "$TIDBIT_DIR/subjects/vim/tidbit.md"
    touch "$TIDBIT_DIR/subjects/vim/motions.md"
}

teardown_tidbit_env() {
    rm -rf "$TIDBIT_DIR"
}
