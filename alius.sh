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
}

function print_alius_text_logo() {
    echo "                                            "
    echo "              ██   █    ▄█   ▄      ▄▄▄▄▄   "
    echo "              █ █  █    ██    █    █     ▀▄ "
    echo "              █▄▄█ █    ██ █   █ ▄  ▀▀▀▀▄   "
    echo "              █  █ ███▄ ▐█ █   █  ▀▄▄▄▄▀    "
    echo "                 █     ▀ ▐ █▄ ▄█            "
    echo "                █           ▀▀▀             "
    echo "               ▀                            "
    echo "                                            "
}

function print_alius_text_picture() {
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
}

# Displays messages inside a text framed box
function print_text_frame() {
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

#########################################################
################# FUNCTIONS ABOVE #######################
#########################################################
############# SCRIPT EXECUTION BELOW ####################
#########################################################

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
print_title_screen
sleep 3

# Completely necessary narrative to begin script
reset
tput bold
tput setaf 27
print_alius_text_picture

if [[ "$machine" == 'Mac' ]]; then
    afplay /System/Library/Sounds/Glass.aiff
fi

tput bold
print_text_frame "                 Hello there, traveler. I'm Alius.                  "
sleep 3
tput bold
print_text_frame '        You look as though you have wondrous tales to share.        '
sleep 3
tput bold
print_text_frame 'Unfortunately, I was not created with the ability to listen to them.'
sleep 3
tput bold
print_text_frame '                        Shall we begin? (y/n)                       '
sleep 1
printf "> " && echo -ne
read input

if [ "$input" = "Y" ] || [ "$input" = "y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ]; then
    tput bold
    print_text_frame '          Our code savior lives! My existence has meaning!          '
    if [[ "$machine" == 'Mac' ]]; then
        afplay /System/Library/Sounds/Funk.aiff
    fi
    sleep 3
    reset
else
    tput bold
    print_text_frame '                  Why must you trouble me? Be gone!                 '
    if [[ "$machine" == 'Mac' ]]; then
        afplay /System/Library/Sounds/Sosumi.aiff
    fi
    sleep 3
    reset
    exit 1
fi

tput setaf 27
print_alius_text_logo
tput sgr0

# Fetch branch updates
print_typed_text "Fetching origin branch updates................" && echo -ne
git checkout -f main &>/dev/null
git fetch --prune &>/dev/null
print_typed_text_green " Fetched " && echo -ne
print_checkmark

# Remove local branches based on remote branch status
print_typed_text "Removing obsolete branches...................." && echo -ne
git removed-branches --prune &>/dev/null
git branch --merged main --no-color | egrep -v '^\s*\*?\s*main$|dev$|qa$|rc$|uat$' | xargs git branch -d &>/dev/null
print_typed_text_green " Removed " && echo -ne
print_checkmark

# Fast-foward all local branches to match the latest state on the remote
print_typed_text "Aligning all branch states...................." && echo -ne
hub sync &>/dev/null
print_typed_text_green " Aligned " && echo -ne
print_checkmark

# Switch to main and update from origin
print_typed_text "Updating main from remote origin.............." && echo -ne
git checkout main &>/dev/null
git pull origin main &>/dev/null
print_typed_text_green " Updated " && echo -ne
print_checkmark

# Check over all origin branches and track any new ones
print_typed_text "Tracking new remote origin branches..........." && echo -ne
for remote in $(git branch -r); do
    git branch --track ${remote#origin/} $remote &>/dev/null
done
print_typed_text_green " Tracked " && echo -ne
print_checkmark

# Iterate over all branches and attempt to apply any new changes in main to the selected branch
print_typed_text "Attempting changes............................" && echo

successCount=0
failureCount=0
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    if [[ "$branch" != *\/* ]]; then
        print_typed_text ">> Checking out " && echo -ne
        print_typed_text_blue "$branch" && echo -ne
        git checkout $branch &>/dev/null
        printf "\n\t"
        print_typed_text_yellow "> PULLING UPDATES FROM ORIGIN" && echo -ne
        git pull --no-edit origin main &>/dev/null
        if [ $? -eq 0 ]; then
            # Clean merge, proceed with pushing
            print_typed_text_green " > CLEAN" && echo -ne
            print_typed_text_green " > PUSHING TO REMOTE ORIGIN" && echo -ne
            git push origin $branch &>/dev/null
            successCount=$((successCount + 1))
        else
            # Conflicted merge, abort and handle manually
            print_typed_text_red " > CONFLICT" && echo -ne
            print_typed_text_red " > ABORTING MERGE" && echo -ne
            git merge --abort &>/dev/null
            failureCount=$((failureCount + 1))
        fi
        printf "\n"
    fi
done

# Print the results after completing all tasks
printf "\n"
print_typed_text "===========================" && echo

print_typed_text_green ">>> Number of successes: " && echo -ne
print_typed_text "$successCount" && echo
print_typed_text_red ">>> Number of failures:  " && echo -ne
print_typed_text "$failureCount" && echo

print_typed_text "===========================" && echo
printf "\n"

# Switch back to main because it looks cleaner at the end
git checkout -f main &>/dev/null
git reset --hard origin/main &>/dev/null
print_typed_text 'Feature branch update complete!' && echo
