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
    branchesToIgnoreCount=0
    branchesToIgnoreArray=()
    branchesToIgnoreText=""

    branchesThatAreAheadCount=0
    branchesThatAreAheadArray=()
    branchesThatAreAheadText=""

    branchesToResetCount=0
    branchesToResetArray=()
    branchesToResetText=""

    branchesToPullCount=0
    branchesToPullArray=()
    branchesToPullText=""

    cleanMergeCount=0
    cleanMergeArray=()
    cleanBranchText=""

    abortedMergeCount=0
    abortedMergeArray=()
    abortedBranchText=""

    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then
            if [[ $(is_in_upstream "$branch") == "1" ]]; then
                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch exists in upstream"
                fi

                # If there's a local branch with the same name as the upstream branch, delete it
                if git show-ref --quiet refs/heads/ASU/$branch; then
                    git branch -D ASU/$branch &>/dev/null
                fi

                upstreamComparison="$(git rev-list --left-right --count ASU/$branch...origin/$branch)"
                upstreamComparisonArray=($upstreamComparison)
                behindCount=${upstreamComparisonArray[0]}
                aheadCount=${upstreamComparisonArray[1]}

                if [[ $behindCount -eq 0 ]] && [[ $aheadCount -eq 0 ]]; then
                    branchesToIgnoreArray+=("$branch")
                    branchesToIgnoreCount=$((branchesToIgnoreCount + 1))

                    if [[ $VERBOSE -eq 1 ]]; then
                        echo "This branch is $aheadCount commits ahead, $behindCount commits behind ASU:$branch"
                        echo "...we will: do nothing"
                    fi
                elif [[ $behindCount -eq 0 ]] && [[ $aheadCount -gt 0 ]]; then
                    git checkout $branch &>/dev/null

                    if git diff-index --quiet ASU/$branch --; then
                        # If there are no file changes, we can safely reset
                        git reset --hard ASU/$branch &>/dev/null
                        git push -f origin $branch &>/dev/null

                        branchesToResetArray+=("$branch")
                        branchesToResetCount=$((branchesToResetCount + 1))

                        if [[ $VERBOSE -eq 1 ]]; then
                            echo "This branch is $aheadCount commits ahead, $behindCount commits behind ASU:$branch"
                            echo "...we will: reset the state to the upstream branch because there are no file changes"
                        fi
                    else
                        # If there are file changes, we ignore
                        branchesToIgnoreArray+=("$branch")
                        branchesToIgnoreCount=$((branchesToIgnoreCount + 1))
                        branchesThatAreAheadArray+=("$branch")
                        branchesThatAreAheadCount=$((branchesThatAreAheadCount + 1))

                        if [[ $VERBOSE -eq 1 ]]; then
                            echo "This branch is $aheadCount commits ahead, $behindCount commits behind ASU:$branch"
                            echo "...we will: do nothing"
                        fi
                    fi
                elif [[ $behindCount -gt 0 ]] && [[ $aheadCount -eq 0 ]]; then
                    git checkout $branch &>/dev/null
                    git reset --hard ASU/$branch &>/dev/null
                    git push -f origin $branch &>/dev/null

                    branchesToResetArray+=("$branch")
                    branchesToResetCount=$((branchesToResetCount + 1))

                    if [[ $VERBOSE -eq 1 ]]; then
                        echo "This branch is $aheadCount commits ahead, $behindCount commits behind ASU:$branch"
                        echo "...we will: reset the state to the upstream branch"
                    fi
                elif [[ $behindCount -gt 0 ]] && [[ $aheadCount -gt 0 ]]; then
                    git checkout $branch &>/dev/null
                    git reset --hard origin/$branch &>/dev/null
                    git pull --no-edit ASU $branch &>/dev/null

                    if [[ $? -eq 0 ]]; then
                        git push origin $branch &>/dev/null

                        cleanMergeArray+=("$branch")
                        cleanMergeCount=$((cleanMergeCount + 1))
                    else
                        git merge --abort &>/dev/null

                        abortedMergeArray+=("$branch")
                        abortedMergeCount=$((abortedMergeCount + 1))
                    fi

                    branchesToPullArray+=("$branch")
                    branchesToPullCount=$((branchesToPullCount + 1))
                    branchesThatAreAheadArray+=("$branch")
                    branchesThatAreAheadCount=$((branchesThatAreAheadCount + 1))

                    if [[ $VERBOSE -eq 1 ]]; then
                        echo "This branch is $aheadCount commits ahead, $behindCount commits behind ASU:$branch"
                        echo "...we will: pull changes from the upstream branch"
                    fi
                fi
            else
                if [[ $VERBOSE -eq 1 ]]; then
                    echo "--> $branch does not exist in upstream"
                fi
            fi

            if [[ $VERBOSE -eq 1 ]]; then
                printf "\n"
            fi
        else
            if [[ $VERBOSE -eq 1 ]]; then
                echo "$branch exists, but it has a forward slash in it"
                # git branch -D $branch
            fi
        fi
    done

    # Switch back to main because it looks cleaner at the end
    git checkout -f main &>/dev/null
    git reset --hard origin/main &>/dev/null

    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Ignored branches that weren't behind upstream" && echo
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Reset branches that weren't ahead but behind upstream" && echo
    print_typed_text "  " && print_checkmark_no_newline && print_typed_text_green " Pulled branches that were ahead and behind upstream" && echo && echo

    if [[ $branchesThatAreAheadCount -gt 0 ]]; then
        print_typed_text "--> You may want to check these branches:" && echo

        firstRun=true
        for value in "${branchesThatAreAheadArray[@]}"; do
            if $firstRun; then
                firstRun=false
                branchesThatAreAheadText="$value"
            else
                branchesThatAreAheadText="$branchesThatAreAheadText, $value"
            fi
        done

        print_typed_text "  $branchesThatAreAheadText" && echo
        print_typed_text "    --> They were ahead of their upstream counterpart, but to avoid losing any in progress work, we can't delete them automatically." && echo
        print_typed_text "    --> If the difference is only merge commits, you can simply run 'git fetch --all && git reset --hard ASU/<branch> && git push -f origin <branch>' to reset them." && echo
    fi

    if [[ $VERBOSE -eq 1 ]]; then
        print_typed_text "The Aliusito CI job completed with the following results:" && echo
        print_typed_text "-- Number of branches to do nothing: $branchesToIgnoreCount" && echo
        print_typed_text "-- Number of branches that were reset: $branchesToResetCount" && echo
        print_typed_text "-- Number of branches that were pulled: $branchesToPullCount" && echo
        print_typed_text "  -- Number of branches that were clean: $cleanMergeCount" && echo
        print_typed_text "  -- Number of branches that were aborted: $abortedMergeCount" && echo

        for value in "${branchesToIgnoreArray[@]}"; do
            branchesToIgnoreText="$branchesToIgnoreText- $value\n"
        done
        for value in "${branchesToResetArray[@]}"; do
            branchesToResetText="$branchesToResetText- $value\n"
        done
        for value in "${branchesToPullArray[@]}"; do
            branchesToPullText="$branchesToPullText- $value\n"
        done
        for value in "${cleanMergeArray[@]}"; do
            cleanBranchText="$cleanBranchText- $value\n"
        done
        for value in "${abortedMergeArray[@]}"; do
            abortedBranchText="$abortedBranchText- $value\n"
        done

        print_typed_text "--- BRANCHES TO IGNORE ---" && echo
        print_typed_text "$branchesToIgnoreText" && echo && echo
        print_typed_text "--- BRANCHES TO RESET ---" && echo
        print_typed_text "$branchesToResetText" && echo && echo
        print_typed_text "--- BRANCHES TO PULL ---" && echo
        print_typed_text "$branchesToPullText" && echo && echo
        print_typed_text "    -- CLEAN --" && echo
        print_typed_text "    $cleanMergeText" && echo && echo
        print_typed_text "    -- ABORTED --" && echo
        print_typed_text "    $abortedMergeText" && echo && echo
    fi
}

#########################################################
################# FUNCTIONS ABOVE #######################
#########################################################
############# SCRIPT EXECUTION BELOW ####################
#########################################################

# Set to 1 for verbose mode
VERBOSE=0

# Title screen
reset && tput setaf 27 && print_title_screen && sleep 3

# Completely necessary narrative to begin script
reset && tput setaf 27 && print_alius_text_logo && tput sgr0

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

# Iterate over all branches and attempt to update them from their upstream counterpart
print_typed_text "Analyzing local branches......................" && echo
start_spinner &
SPIN_PID=$!
trap "kill -9 $SPIN_PID" $(seq 0 15)
execute_changes
