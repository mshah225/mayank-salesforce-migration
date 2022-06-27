#!/bin/bash

function print_title_screen() {
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "    ██   █    ▄█   ▄      ▄▄▄▄▄   ▄█    ▄▄▄▄▀ ████▄ █  ▄▄▄▄▄      "
    echo "    █ █  █    ██    █    █     ▀▄ ██ ▀▀▀ █    █   █   █     ▀▄    "
    echo "    █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   ██     █    █   █ ▄  ▀▀▀▀▄      "
    echo "    █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    ▐█    █     ▀████  ▀▄▄▄▄▀       "
    echo "       █     ▀ ▐ █▄ ▄█             ▐   ▀                          "
    echo "      █           ▀▀▀                                             "
    echo "     ▀                                                            "
    echo "          _    ____ ____ ___    ____ ___ ____ _  _ ___            "
    echo "          |    |__| [__   |     [__   |  |__| |\ | |  \           "
    echo "          |___ |  | ___]  |     ___]  |  |  | | \| |__/           "
    echo "                                                                  "
    echo "                                     by Michael Gilardi           "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "
    echo "                                                                  "

}

function print_alius_text_logo() {
    echo "                                                      "
    echo "    ██   █    ▄█   ▄      ▄▄▄▄▄   ▄█    ▄▄▄▄▀ ████▄   "
    echo "    █ █  █    ██    █    █     ▀▄ ██ ▀▀▀ █    █   █   "
    echo "    █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   ██     █    █   █   "
    echo "    █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    ▐█    █     ▀████   "
    echo "       █     ▀ ▐ █▄ ▄█             ▐   ▀              "
    echo "      █           ▀▀▀                                 "
    echo "     ▀                                                "
    echo "                                                      "
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

function print_typed_text_yellow() {
    local message="$@"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;33m${message:$i:1}\033[0m"
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

# Check if a branch exists within the upstream repository
function is_in_upstream() {
    local branch="$@"
    local existed_in_upstream=$(git ls-remote --heads ASU ${branch})

    if [[ -z ${existed_in_upstream} ]]; then
        echo 0
    else
        echo 1
    fi
}

# Check if a branch contains an undesirable keyword
function is_ignored_branch() {
    local local branch="$@"

    if [[ "$branch" == *"migration"* ]] || [[ "$branch" == *"merge"* ]] || [[ "$branch" == *"sync"* ]] || [[ "$branch" == *"bridge"* ]] || [[ "$branch" == *"revert"* ]]; then
        echo 1
    else
        echo 0
    fi
}

# Check if a branch is protected
function is_protected_branch() {
    local branch="$@"
    local protected_branches=("dev main master sync sync-pr qa uat")

    if [[ " ${protected_branches[*]} " =~ " ${branch} " ]]; then
        echo 1
    else
        echo 0
    fi
}

# Execute all major logic
function execute_changes() {
    branchesToSkipCount=0
    branchesToSkipArray=()

    branchesToCreatePullRequestCount=0
    branchesToCreatePullRequestArray=()

    branchesToPushCount=0
    branchesToPushArray=()

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

            if [[ $(is_protected_branch "$branch") == "1" ]] || [[ $(is_ignored_branch "$branch") == "1" ]] ; then
                branchesToSkipArray+=("$branch")
                branchesToSkipCount=$((branchesToSkipCount + 1))
                continue
            fi

            mainComparison="$(git rev-list --left-right --count ASU/main...origin/$branch)"
            mainComparisonArray=($mainComparison)
            behindMainCount=${mainComparisonArray[0]}
            aheadMainCount=${mainComparisonArray[1]}

            if [[ $aheadMainCount -eq 0 ]]; then
                branchesToSkipArray+=("$branch")
                branchesToSkipCount=$((branchesToSkipCount + 1))
                continue
            fi

            # Attempt to pull from ASU:main to keep branch up-to-date if there are no conflicts
            if [[ $behindMainCount -gt 0 ]]; then
                git pull --no-edit ASU main &>/dev/null
                if [ $? -eq 0 ]; then
                    git push origin $branch &>/dev/null
                else
                    git merge --abort &>/dev/null
                fi
            fi

            if [[ $(is_in_upstream "$branch") == "1" ]]; then
                upstreamComparison="$(git rev-list --left-right --count ASU/$branch...origin/$branch)"
                upstreamComparisonArray=($upstreamComparison)
                behindUpstreamCount=${upstreamComparisonArray[0]}
                aheadUpstreamCount=${upstreamComparisonArray[1]}

                if [[ $aheadUpstreamCount -eq 0 ]]; then
                    branchesToSkipArray+=("$branch")
                    branchesToSkipCount=$((branchesToSkipCount + 1))
                    continue
                fi

                # Attempt to pull from ASU upstream to keep branch up-to-date if there are no conflicts
                if [[ $behindUpstreamCount -gt 0 ]]; then
                    git pull --no-edit ASU $branch &>/dev/null
                    if [ $? -eq 0 ]; then
                        git push origin $branch &>/dev/null
                    else
                        git merge --abort &>/dev/null
                    fi
                fi

                #hub pull-request --base ASU:$branch --message "ASU/$branch: do we want these changes?" &>/dev/null
                branchesToCreatePullRequestArray+=("$branch")
                branchesToCreatePullRequestCount=$((branchesToCreatePullRequestCount + 1))
            else
                #git push ASU $branch &>/dev/null
                branchesToPushArray+=("$branch")
                branchesToPushCount=$((branchesToPushCount + 1))
            fi
        fi
    done

    # Switch back to main because it looks cleaner at the end
    git checkout -f main &>/dev/null
    git reset --hard origin/main &>/dev/null
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Completed branch analyzation" && echo && echo

    print_typed_text "Aliusito succeeded with the following results:" && echo
    print_typed_text "-- Number of branches to contribute upstream: $branchesToPushCount" && echo
    print_typed_text "-- Number of branches to create PR for review: $branchesToCreatePullRequestCount" && echo
    print_typed_text "-- Number of branches to skip due to irrelevancy: $branchesToSkipCount" && echo && echo

    print_typed_text_blue "--- PUSHED BRANCHES ---" && echo
    for value in "${branchesToPushArray[@]}"; do
        print_typed_text_green "- $value"
        printf "\n"
    done

    echo && print_typed_text_blue "--- PULL REQUESTED BRANCHES ---" && echo
    for value in "${branchesToCreatePullRequestArray[@]}"; do
        print_typed_text_yellow "- $value"
        printf "\n"
    done

    echo && print_typed_text_blue "--- SKIPPED BRANCHES ---" && echo
    for value in "${branchesToSkipArray[@]}"; do
         print_typed_text_red "- $value"
         printf "\n"
    done

    print_typed_text "Closing terminal instance in two minutes." && echo
}

function main() {
    # Title screen
    reset && tput setaf 27 && print_title_screen && sleep 5

    # Completely necessary narrative to begin script
    reset && tput setaf 27 && print_alius_text_logo && tput sgr0

    # Fetch branch updates
    print_typed_text "Adding ASU as a remote........................" && echo -ne
    git remote add ASU https://github.com/ASU/crm-salesforce-enterpise &>/dev/null
    print_typed_text_green " Remoted " && echo -ne && print_checkmark

    # Fetch branch updates
    print_typed_text "Fetching all branch updates..................." && echo -ne
    git checkout -f main &>/dev/null && git fetch --prune ASU &>/dev/null && git fetch --prune origin &>/dev/null
    print_typed_text_green " Fetched " && echo -ne && print_checkmark

    # Fast-foward all local branches to match the latest state on the remote
    print_typed_text "Aligning all branch states...................." && echo -ne
    hub sync &>/dev/null
    print_typed_text_green " Aligned " && echo -ne && print_checkmark

    # Switch to main and update from origin
    print_typed_text "Updating main from upstream..................." && echo -ne
    git reset --hard ASU/main &>/dev/null
    git push -f origin main &>/dev/null
    print_typed_text_green " Updated " && echo -ne && print_checkmark

    # Check over all origin branches and track any new ones
    print_typed_text "Tracking new remote origin branches..........." && echo -ne
    for remote in $(git branch -r); do
        if [[ ${remote} == "origin/"* ]]; then
            git branch --track ${remote#origin/} $remote &>/dev/null
        fi
    done
    print_typed_text_green " Tracked " && echo -ne && print_checkmark

    # hub authentication check
    print_typed_text "Checking hub authentication..................." && echo -ne
    hub checkout http://github.com/apple/swift/pull/862 &>/dev/null
    print_typed_text_green " Checked " && echo -ne && print_checkmark

    # Iterate over all branches and attempt to update them from their upstream counterpart
    print_typed_text "Analyzing local branches...................... " && echo
    execute_changes
}

reset && reset
main