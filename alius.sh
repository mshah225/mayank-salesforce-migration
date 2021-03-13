#!/bin/bash

# Displays messages inside a text framed box
function text_frame() {
    local s=("$@") b w
    for l in "${s[@]}"; do
        ((w < ${#l})) && {
            b="$l"
            w="${#l}"
        }
    done
    tput setaf 8
    echo " -${b//?/-}-
| ${b//?/ } |"
    for l in "${s[@]}"; do
        printf '| %s%*s%s |\n' "$(tput setaf 27)" "-$w" "$l" "$(tput setaf 8)"
    done
    echo "| ${b//?/ } |
 -${b//?/-}-"
    tput sgr 0
}

# Figure out the machine type
unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

# Title screen
reset
tput setaf 27
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "            ██   █    ▄█   ▄      ▄▄▄▄▄               "
echo "            █ █  █    ██    █    █     ▀▄             "
echo "            █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄               "
echo "            █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀                "
echo "               █     ▀ ▐ █▄ ▄█                        "
echo "              █           ▀▀▀                         "
echo "             ▀                                        "
echo "                      by Michael Gilardi              "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
echo "                                                      "
sleep 3

# Completely necessary narrative to begin script
reset
tput bold
tput setaf 27
echo "                                                           "
echo "                                     ____                  "
echo "                                   .'* *.'                 "
echo "                                __/_*_*(_                  "
echo "                               / _______ \                 "
echo "                              _\_)/___\(_/_                "
echo "                             / _((\- -/))_ \               "
echo "                             \ \())(-)(()/ /               "
echo "                              ' \(((()))/ '                "
echo "                             / ' \)).))/ ' \               "
echo "                            / _ \ - | - /_  \              "
echo "                           (   ( .;''';. .'  )             "
echo "                           _\'__ /    )\ __'/_             "
echo "                             \/  \   ' /  \/               "
echo "                              .'  '...' ' )                "
echo "                               / /  |  \ \                 "
echo "                              / .   .   . \                "
echo "                             /   .     .   \               "
echo "                            /   /   |   \   \              "
echo "                          .'   /    b    '.  '.            "
echo "                      _.-'    /     Bb     '-. '-._        "
echo "                  _.-'       |      BBb       '-.  '-.     "
echo "                 (___________\____.dBBBb.________)____)    "

if [[ "$machine" == 'Mac' ]]; then
    afplay /System/Library/Sounds/Glass.aiff
fi

tput bold
text_frame "                 Hello there, traveler. I'm Alius.                  "
sleep 3
tput bold
text_frame '        You look as though you have wondrous tales to share.        '
sleep 3
tput bold
text_frame 'Unfortunately, I was not created with the ability to listen to them.'
sleep 3
tput bold
text_frame '                        Shall we begin? (y/n)                       '
sleep 1
printf "> "
echo -ne
read input

if [ "$input" = "Y" ] || [ "$input" = "y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ]; then
    tput bold
    text_frame '          Our code savior lives! My existence has meaning!          '
    if [[ "$machine" == 'Mac' ]]; then
        afplay /System/Library/Sounds/Funk.aiff
    fi
    sleep 3
    reset
else
    tput bold
    text_frame '                  Why must you trouble me? Be gone!                 '
    if [[ "$machine" == 'Mac' ]]; then
        afplay /System/Library/Sounds/Sosumi.aiff
    fi
    sleep 3
    reset
    exit 1
fi

tput bold
text_frame '         Which path will you take, traveler? Choose wisely.         '
sleep 1

message="[1] I'm on an original repository and I have no upstream."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
message="[2] I'm on a fork of the original repository and I want to pull upstream updates."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
message="[3] I'm on a fork of the original repository and I DO NOT want to pull upstream updates (not recommended)."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
printf "> "
echo -ne
read choice
echo

# If the user wants to additionally update their fork from upstream, proceed with the following
remote=''
if [ "$choice" = "2" ]; then
    tput bold
    text_frame '        Hark! After an arduous search, I found your remotes.        '
    sleep 1
    git remote

    tput bold
    text_frame "   The time has come to choose your fork's upstream. What say you?  "
    sleep 1
    printf "> "
    echo -ne
    read remote
fi

reset
tput setaf 27
echo "                                            "
echo "              ██   █    ▄█   ▄      ▄▄▄▄▄   "
echo "              █ █  █    ██    █    █     ▀▄ "
echo "              █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   "
echo "              █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    "
echo "                 █     ▀ ▐ █▄ ▄█            "
echo "                █           ▀▀▀             "
echo "               ▀                            "
echo "                                            "
tput sgr0

# Fetch branch updates
message="Fetching origin branch updates................"
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo -ne
git checkout -f main &>/dev/null
git fetch --prune &>/dev/null
message=" Fetched "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Remove local branches based on remote branch status
message="Removing obsolete branches...................."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo -ne
git removed-branches --prune &>/dev/null
git branch --merged main --no-color | egrep -v '^\s*\*?\s*main$|dev$|qa$|rc$|uat$' | xargs git branch -d &>/dev/null
message=" Removed "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Fast-foward all local branches to match the latest state on the remote
message="Aligning all branch states...................."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo -ne
hub sync &>/dev/null
message=" Aligned "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Switch to main and update from origin
message="Updating main from remote origin.............."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo -ne
git checkout main &>/dev/null
git pull origin main &>/dev/null
message=" Updated "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Check over all origin branches and track any new ones
message="Tracking new remote origin branches..........."
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo -ne
for remote in $(git branch -r); do
    git branch --track ${remote#origin/} $remote &>/dev/null
done
message=" Tracked "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Iterate over all branches and attempt to apply any new changes in main to the selected branch
message="Attempting changes............................"
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo

successCount=0
failureCount=0
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    if [[ "$branch" != *\/* ]]; then
        message=">> Checking out "
        for ((i = 0; i < ${#message}; i++)); do
            echo "after 5" | tclsh
            printf "${message:$i:1}"
        done
        echo -ne
        message="$branch"
        for ((i = 0; i < ${#message}; i++)); do
            echo "after 5" | tclsh
            printf "\033[1;34m${message:$i:1}\033[0m"
        done
        echo -ne
        git checkout $branch &>/dev/null
        printf "\n\t"
        message="> PULLING UPDATES FROM MAIN"
        for ((i = 0; i < ${#message}; i++)); do
            echo "after 5" | tclsh
            printf "\033[1;33m${message:$i:1}\033[0m"
        done
        echo -ne
        git pull --no-edit origin main &>/dev/null
        if [ $? -eq 0 ]; then
            # Clean merge, proceed with pushing
            message=" > CLEAN"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;32m${message:$i:1}\033[0m"
            done
            echo -ne
            message=" > PUSHING TO REMOTE ORIGIN"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;32m${message:$i:1}\033[0m"
            done
            echo -ne
            git push origin $branch &>/dev/null
            successCount=$((successCount + 1))
        else
            # Conflicted merge, abort and handle manually
            message=" > CONFLICT"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;31m${message:$i:1}\033[0m"
            done
            echo -ne
            message=" > ABORTING MERGE"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;31m${message:$i:1}\033[0m"
            done
            echo -ne
            git merge --abort &>/dev/null
            failureCount=$((failureCount + 1))
        fi
        printf "\n"
    fi
done

if [ "$choice" = "2" ]; then
    reset
    tput setaf 27
    echo "                                            "
    echo "              ██   █    ▄█   ▄      ▄▄▄▄▄   "
    echo "              █ █  █    ██    █    █     ▀▄ "
    echo "              █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   "
    echo "              █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    "
    echo "                 █     ▀ ▐ █▄ ▄█            "
    echo "                █           ▀▀▀             "
    echo "               ▀         FORK EDITION       "
    echo "                                            "
    tput sgr0

    # Check over all origin branches and track any new ones
    message="Looking for upstream changes.................."
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
    echo -ne
    git checkout -f origin main &>/dev/null
    git reset --hard origin/main &>/dev/null
    message=" Handled "
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;32m${message:$i:1}\033[0m"
    done
    echo -ne
    printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

    # Fetch branch updates
    message="Fetching upstream branch updates.............."
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
    echo -ne
    git fetch --all --prune &>/dev/null
    message=" Fetched "
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;32m${message:$i:1}\033[0m"
    done
    echo -ne
    printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

    # Iterate over all branches and attempt to apply any new changes in main to the selected branch
    message="Attempting to pull changes from upstream......"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
    echo

    successCountUpstream=0
    failureCountUpstream=0
    for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
        if [[ "$branch" != *\/* ]]; then
            message=">> Checking out "
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "${message:$i:1}"
            done
            echo -ne
            message="$branch"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;34m${message:$i:1}\033[0m"
            done
            echo -ne
            git checkout $branch
            printf "\n\t"
            message="> PULLING UPDATES FROM UPSTREAM"
            for ((i = 0; i < ${#message}; i++)); do
                echo "after 5" | tclsh
                printf "\033[1;33m${message:$i:1}\033[0m"
            done
            echo -ne
            git pull --no-edit $remote $branch
            if [ $? -eq 0 ]; then
                # Clean merge, proceed with pushing
                message=" > CLEAN"
                for ((i = 0; i < ${#message}; i++)); do
                    echo "after 5" | tclsh
                    printf "\033[1;32m${message:$i:1}\033[0m"
                done
                echo -ne
                message=" > PUSHING TO REMOTE ORIGIN"
                for ((i = 0; i < ${#message}; i++)); do
                    echo "after 5" | tclsh
                    printf "\033[1;32m${message:$i:1}\033[0m"
                done
                echo -ne
                git push origin $branch
                successCountUpstream=$((successCountUpstream + 1))
            else
                # Conflicted merge, abort and handle manually
                message=" > CONFLICT"
                for ((i = 0; i < ${#message}; i++)); do
                    echo "after 5" | tclsh
                    printf "\033[1;31m${message:$i:1}\033[0m"
                done
                echo -ne
                message=" > ABORTING MERGE"
                for ((i = 0; i < ${#message}; i++)); do
                    echo "after 5" | tclsh
                    printf "\033[1;31m${message:$i:1}\033[0m"
                done
                echo -ne
                git merge --abort
                failureCountUpstream=$((failureCountUpstream + 1))
            fi
            printf "\n"
        fi
    done
fi

# Print the results after completing all tasks
printf "\n"
message="==========================="
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo

message=">>> Number of successes: "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;32m${message:$i:1}\033[0m"
done
echo -ne
message="$successCount"
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
message=">>> Number of failures:  "
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "\033[1;31m${message:$i:1}\033[0m"
done
echo -ne
message="$failureCount"
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo

if [ "$choice" = "2" ]; then
    echo
    message=">>> Number of upstream successes: "
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;32m${message:$i:1}\033[0m"
    done
    echo -ne
    message="$successCountUpstream"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
    echo
    message=">>> Number of upstream failures:  "
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "\033[1;31m${message:$i:1}\033[0m"
    done
    echo -ne
    message="$failureCountUpstream"
    for ((i = 0; i < ${#message}; i++)); do
        echo "after 5" | tclsh
        printf "${message:$i:1}"
    done
    echo
fi

message="==========================="
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
printf "\n"

# Switch back to main because it looks cleaner at the end
git checkout -f origin main &>/dev/null
git reset --hard origin/main &>/dev/null
message='Feature branch update complete!'
for ((i = 0; i < ${#message}; i++)); do
    echo "after 5" | tclsh
    printf "${message:$i:1}"
done
echo
