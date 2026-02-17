#!/bin/bash

ERROR_LOG="errors.log"

log_error(){
    echo "Error: $1" | tee -a "$ERROR_LOG"
}

# 3. Here Document
show_help(){
cat <<EOF
Usage: ./file_analyzer.sh [OPTIONS]
Options:
    -d <directory>  Directory to search recursively
    -k <keyword>    Keyword to search
    -f <file>       File to search directly
    --help          Display this help menu

Examples:
    ./file_analyzer.sh -d logs -k error
    ./file_analyzer.sh -f script.sh -k TODO
EOF
}

# 6. getopts
while getopts ":d:k:f:-:" opt
do
    case $opt in
        d) DIRECTORY="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        -)
            if [[ "$OPTARG" == "help" ]]
            then
                show_help
                exit 0
            fi
            ;;
        *)
            log_error "Invalid option"
            show_help
            exit 1
            ;;
    esac
done

# 1. Recursive function
recursive_search(){
    # 2. Error handling
    if [ "$#" -ne 2 ]
    then
        log_error "Invalid number of arguments"
        return
    fi

    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*
    do
        if [[ -f "$item" ]]
        then
            if grep -q "$keyword" "$item" 2>>"$ERROR_LOG"
            then
                echo "Keyword '$keyword' found in file: $item"
            fi
        elif [[ -d "$item" ]]
        then
            recursive_search "$item" "$keyword"
        fi
    done
}

# If file option is used
if [[ -n "$FILE" ]]
then
    if [[ ! -f "$FILE" ]]
    then
        log_error "File $FILE does not exist"
        exit 1
    fi

    echo "Searching in file: $FILE"

    grep "$KEYWORD" <<< "$(cat "$FILE")" 2>>"$ERROR_LOG"

    if [ $? -eq 0 ]
    then
        echo "Keyword found"
    else
        echo "Keyword not found"
    fi

    exit 0
fi

# 4. Special parameters
echo "Script name: $0"
echo "Total arguments passed: $#"
echo "All arguments: $@"

# 5. Regex validation
if [[ -z "$KEYWORD" || ! "$KEYWORD" =~ ^[a-zA-Z0-9]+$ ]]
then
    log_error "Invalid or empty keyword"
    exit 1
fi

# Run recursive search if directory is given
if [[ -n "$DIRECTORY" ]]
then
    if [[ ! -d "$DIRECTORY" ]]
    then
        log_error "Directory $DIRECTORY does not exist"
        exit 1
    fi

    echo "Searching recursively in directory: $DIRECTORY"
    recursive_search "$DIRECTORY" "$KEYWORD"
fi
