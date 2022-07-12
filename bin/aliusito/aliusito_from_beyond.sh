#!/bin/bash

function print_title_screen() {
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "    ██   █    ▄█   ▄      ▄▄▄▄▄   ▄█    ▄▄▄▄▀ ████▄   "
    echo "    █ █  █    ██    █    █     ▀▄ ██ ▀▀▀ █    █   █   "
    echo "    █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   ██     █    █   █   "
    echo "    █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    ▐█    █     ▀████   "
    echo "       █     ▀ ▐ █▄ ▄█             ▐   ▀              "
    echo "      █           ▀▀▀                                 "
    echo "     ▀                                                "
    echo "                      by Michael Gilardi              "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "
    echo "                                                      "

}

function print_alius_text_logo() {
    echo "                                                       "
    echo "    ██   █    ▄█   ▄      ▄▄▄▄▄   ▄█    ▄▄▄▄▀ ████▄    "
    echo "    █ █  █    ██    █    █     ▀▄ ██ ▀▀▀ █    █   █    "
    echo "    █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   ██     █    █   █    "
    echo "    █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    ▐█    █     ▀████    "
    echo "       █     ▀ ▐ █▄ ▄█             ▐   ▀               "
    echo "      █           ▀▀▀                                  "
    echo "     ▀                                                 "
    echo "                                                       "
}

# Print text as if it's being typed live
function print_typed_text() {
    local message="$@"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
}

function print_typed_text_blue() {
    local message="$@"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;34m${message:$i:1}\033[0m"
    done
}

function print_typed_text_green() {
    local message="$@"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;32m${message:$i:1}\033[0m"
    done
}

function print_typed_text_red() {
    local message="$@"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;31m${message:$i:1}\033[0m"
    done
}

# Print a green checkmark
function print_checkmark() {
    printf "\033[1;32m\xE2\x9C\x94\033[0m\n"
}

# Print a green checkmark without a newline
function print_checkmark_no_newline() {
    printf "\033[1;32m\xE2\x9C\x94\033[0m"
}


# Execute all major logic
function execute_changes() {
    branchesToDeleteCount=0
    branchesToDeleteArray=()

    branchTotalCount=0
    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then
            branchTotalCount=$((branchTotalCount + 1))
        fi
    done

    branchIndex=0
    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then
            branchIndex=$((branchIndex + 1))
            echo -ne "  --> \033[1m$branch\033[0m ($branchIndex/$branchTotalCount)\033[0K\r"

            mainComparison="$(git rev-list --left-right --count ASU/main...origin/$branch)"
            mainComparisonArray=($mainComparison)
            behindMainCount=${mainComparisonArray[0]}
            aheadMainCount=${mainComparisonArray[1]}

            if [[ $aheadMainCount -gt 0 ]]; then
                git checkout $branch &>/dev/null
                if git diff-index --quiet origin/main --; then
                    git checkout -f main &>/dev/null
                    # git branch -D $branch
                    # git push origin --delete $branch
                    branchesToDeleteArray+=("$branch")
                    branchesToDeleteCount=$((branchesToDeleteCount + 1))
                fi
            fi
        fi
    done

    # Switch back to main because it looks cleaner at the end
    git checkout -f main
    git reset --hard origin/main
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Completed branch analyzation" && echo && echo

    print_typed_text "Aliusito succeeded with the following results:" && echo
    print_typed_text "-- Number of branches to be deleted: $branchesToDeleteCount" && echo

    print_typed_text_blue "--- DELETED BRANCHES ---" && echo
    for value in "${branchesToDeleteArray[@]}"; do
        print_typed_text_red "- $value"
        printf "\n"
    done
}

function main() {
    # Title screen
    reset && tput setaf 27 && print_title_screen && sleep 5

    # Completely necessary narrative to begin script
    reset && tput setaf 27 && print_alius_text_logo && tput sgr0

    # Fast-foward all local branches to match the latest state on the remote
    print_typed_text "Aligning all branch states...................." && echo -ne
    git checkout -f main && hub sync && git reset --hard origin/main
    print_typed_text_green " Aligned " && echo -ne && print_checkmark

    # Check over all origin branches and track any new ones
    print_typed_text "Tracking new remote origin branches..........." && echo -ne
    for remote in $(git branch -r); do
        if [[ ${remote} == "origin/"* ]]; then
            git branch --track ${remote#origin/} $remote
        fi
    done
    print_typed_text_green " Tracked " && echo -ne && print_checkmark

    # Iterate over all branches and attempt to update them from their upstream counterpart
    print_typed_text "Analyzing local branches...................... " && echo
    execute_changes
}

reset && reset && reset
main
