_tidbit_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local tidbit_dir
    tidbit_dir="$(dirname "$(command -v tidbit)")"

    case "$COMP_CWORD" in
        1)
            local subjects commands
            subjects=$(ls "$tidbit_dir/subjects/" 2>/dev/null)
            commands="help version config"
            COMPREPLY=($(compgen -W "$subjects $commands" -- "$cur"))
            ;;
        2)
            local subject="${COMP_WORDS[1]}"
            local file_extension
            file_extension=$(grep "^file_extension=" "$tidbit_dir/.tidbitconfig" 2>/dev/null | cut -d= -f2)
            file_extension="${file_extension:-md}"
            local files
            files=$(ls "$tidbit_dir/subjects/$subject/" 2>/dev/null | sed "s/\.$file_extension$//")
            COMPREPLY=($(compgen -W "$files" -- "$cur"))
            ;;
    esac
}
complete -F _tidbit_complete tidbit
