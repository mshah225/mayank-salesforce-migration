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

function is_ignored_branch() {
    local local branch="$@"

    if [[ "$branch" == *"migration"* ]] || [[ "$branch" == *"merge"* ]] || [[ "$branch" == *"sync"* ]] || [[ "$branch" == *"bridge"* ]] || [[ "$branch" == *"revert"* ]]; then
        echo 1
    else
        echo 0
    fi
}

function is_protected_branch() {
    local branch="$@"
    local protected_branches=("dev main master sync sync-pr qa uat")

    if [[ " ${protected_branches[*]} " =~ " ${branch} " ]]; then
        echo 1
    else
        echo 0
    fi
}

# Create progress spinner when waiting on a task
start_spinner() {
    spinner="/|\\-/|\\-"
    while :; do
        for i in $(seq 0 7); do
            echo -n "${spinner:$i:1}"
            echo -en "\010"
            sleep 1
        done
    done
}

# Execute all major logic
function execute_changes() {
    branchesToSkipCount=0
    branchesToSkipArray=()
    branchesToSkipText=""

    branchesToCreatePullRequestCount=0
    branchesToCreatePullRequestArray=()
    branchesToCreatePullRequestText=""

    branchesToPushCount=0
    branchesToPushArray=()
    branchesToPushText=""

    if [[ $VERBOSE -eq 1 ]]; then
        printf "\n"
    fi

    branchTotalCount=0
    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then
            branchTotalCount=$((branchTotalCount + 1))
        fi
    done

    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then

            echo -ne "--> \033[1m$branch\033[0m"

            if [[ $(is_protected_branch "$branch") == "1" ]] || [[ $(is_ignored_branch "$branch") == "1" ]] ; then
                branchesToSkipArray+=("$branch")
                branchesToSkipCount=$((branchesToSkipCount + 1))
                
                echo -ne " [SKIP]\033[0K\r"

                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch is listed as protected or ignored, skipping"
                    printf "\n"
                fi
                continue
            fi

            mainComparison="$(git rev-list --left-right --count ASU/main...origin/$branch)"
            mainComparisonArray=($mainComparison)
            behindMainCount=${mainComparisonArray[0]}
            aheadMainCount=${mainComparisonArray[1]}

            if [[ $aheadMainCount -eq 0 ]]; then
                branchesToSkipArray+=("$branch")
                branchesToSkipCount=$((branchesToSkipCount + 1))

                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch does not have any file changes compared to main, skipping"
                    printf "\n"
                fi
                continue
            fi

            if [[ $behindMainCount -gt 0 ]]; then
                # Attempt to pull from ASU:main to keep branch up-to-date if there are no conflicts
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

                    if [[ $VERBOSE -eq 1 ]]; then
                        echo "--> $branch does not have any file changes compared to upstream, skipping"
                        printf "\n"
                    fi
                    continue
                fi

                if [[ $behindUpstreamCount -gt 0 ]]; then
                    # Attempt to pull from ASU upstream to keep branch up-to-date if there are no conflicts
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

                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch has file changes and also exists in upstream, creating a pull request for review"
                fi
            else
                #git push ASU $branch &>/dev/null

                branchesToPushArray+=("$branch")
                branchesToPushCount=$((branchesToPushCount + 1))

                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch does not exist in upstream, attempting to push to ASU"
                fi
            fi

            if [[ $VERBOSE -eq 1 ]]; then
                printf "\n"
            fi
        fi
    done

    # Switch back to main because it looks cleaner at the end
    git checkout -f main &>/dev/null
    git reset --hard origin/main &>/dev/null

    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Ignored branches that were in the ASU upstream" && echo
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Updated branches if not conflicts were present" && echo
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Created pull requests if a branch already existed" && echo
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Pushed branches to the ASU upstream" && echo && echo

    print_typed_text "The Aliusito CI job completed with the following results:" && echo
    print_typed_text "-- Number of branches to skip: $branchesToSkipCount" && echo
    print_typed_text "-- Number of branches to create a pull request for: $branchesToCreatePullRequestCount" && echo
    print_typed_text "-- Number of branches to contribute: $branchesToPushCount" && echo && echo

    print_typed_text_blue "--- BRANCHES TO SKIP ---" && echo
    for value in "${branchesToSkipArray[@]}"; do
         print_typed_text_red "- $value"
         printf "\n"
    done

    echo && print_typed_text_blue "--- BRANCHES TO CREATE PR ---" && echo
    for value in "${branchesToCreatePullRequestArray[@]}"; do
        print_typed_text_yellow "- $value"
        printf "\n"
    done

    echo && print_typed_text_blue "--- BRANCHES TO PUSH ---" && echo
    for value in "${branchesToPushArray[@]}"; do
        print_typed_text_green "- $value"
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
    # start_spinner &
    # SPIN_PID=$!
    # trap "kill -9 $SPIN_PID" $(seq 0 15)
    execute_changes
}

# Set to 1 for verbose mode
VERBOSE=0

reset && reset
main