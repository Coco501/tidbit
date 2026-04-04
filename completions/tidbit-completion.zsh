_tidbit() {
    local tidbit_dir
    tidbit_dir="$(dirname "$(command -v tidbit)")"

    case $CURRENT in
        2)
            local subjects commands
            subjects=($(ls "$tidbit_dir/subjects/" 2>/dev/null))
            commands=(help version config)
            _describe 'commands' commands
            _describe 'subjects' subjects
            ;;
        3)
            local subject="${words[2]}"
            local file_extension
            file_extension=$(grep "^file_extension=" "$tidbit_dir/.tidbitconfig" 2>/dev/null | cut -d= -f2)
            file_extension="${file_extension:-md}"
            local files
            files=($(ls "$tidbit_dir/subjects/$subject/" 2>/dev/null | sed "s/\.$file_extension$//"))
            _describe 'files' files
            ;;
    esac
}

if (( $+functions[compdef] )); then
    compdef _tidbit tidbit
fi
