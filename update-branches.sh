#!/bin/bash

# Title screen
reset
echo "                                                                  ";
echo "                                                                  ";
echo "        ██    ██ ██████  ██████   █████  ████████ ███████         ";
echo "        ██    ██ ██   ██ ██   ██ ██   ██    ██    ██              ";
echo "        ██    ██ ██████  ██   ██ ███████    ██    █████           ";
echo "        ██    ██ ██      ██   ██ ██   ██    ██    ██              ";
echo "         ██████  ██      ██████  ██   ██    ██    ███████         ";
echo "                                                                  ";
echo "                                                                  ";
echo "    ███████ ███████  █████  ████████ ██    ██ ██████  ███████     ";
echo "    ██      ██      ██   ██    ██    ██    ██ ██   ██ ██          ";
echo "    █████   █████   ███████    ██    ██    ██ ██████  █████       ";
echo "    ██      ██      ██   ██    ██    ██    ██ ██   ██ ██          ";
echo "    ██      ███████ ██   ██    ██     ██████  ██   ██ ███████     ";
echo "                                                                  ";
echo "                                                                  ";
echo "██████  ██████   █████  ███    ██  ██████ ██   ██ ███████ ███████ ";
echo "██   ██ ██   ██ ██   ██ ████   ██ ██      ██   ██ ██      ██      ";
echo "██████  ██████  ███████ ██ ██  ██ ██      ███████ █████   ███████ ";
echo "██   ██ ██   ██ ██   ██ ██  ██ ██ ██      ██   ██ ██           ██ ";
echo "██████  ██   ██ ██   ██ ██   ████  ██████ ██   ██ ███████ ███████ ";
echo "                                                                  ";
echo "                                                                  ";
sleep 3

# Completely necessary narrative to begin script
reset
echo "########################################################################";
message="# Hello there, traveler."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo -ne;
sleep 1
message=" I'm Alius."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
printf "#\n"
message="# You look as though you have wondrous tales to share."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="# Unfortunately, I was not created with the ability to listen to them."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
printf "#\n"
message="# I trust that you have not come with devious intent."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="# Shall we begin? (y/n) "; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo -ne;

read input
if [ "$input" = "Y" ] || [ "$input" = "y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ]; then
    printf "#\n"
    message='# Our code savior lives!'; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
    echo "########################################################################";
    sleep 3
    reset
else
    printf "#\n"
    message='# I have no time for hooligans. Be gone!'; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
    echo "########################################################################";
    sleep 3
    return
fi

# Fetch and apply all branch updates
message="Fetching all branch updates..................."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
git fetch --all &>/dev/null
message=" Fetched "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"
message="Syncing all branch updates...................."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
hub sync &>/dev/null
message=" Synced  "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Switch to main and update from origin
message="Updating main from remote origin............"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
git checkout main &>/dev/null
git pull origin main &>/dev/null
message=" Updated "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Check over all origin branches and track any new ones
message="Tracking new remote origin branches..........."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
for remote in `git branch -r`; do 
    git branch --track ${remote#origin/} $remote &>/dev/null
done
message=" Tracked "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
printf "\033[1;32m\xE2\x9C\x94\033[0m\n"

# Iterate over all branches and attempt to apply any new changes in main to the selected branch
message="Attempting changes............................"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
successCount=0
failureCount=0
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    message=">> Checking out "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
    message="$branch"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;34m${message:$i:1}\033[0m"; done; echo -ne;
    git checkout $branch &>/dev/null
    printf "\n\t"
    message="> PULLING UPDATES"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;33m${message:$i:1}\033[0m"; done; echo -ne;
    git pull --no-edit origin main &>/dev/null
    if [ $? -eq 0 ]; then
        # Clean merge, proceed with pushing
        printf "\n\t"
        message="> CLEAN MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
        printf "\n\t"
        message="> PUSHING UPDATES"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
        git push origin $branch &>/dev/null
        successCount=$((successCount+1))
    else
        # Conflicted merge, abort and handle manually
        printf "\n\t"
        message="> CONFLICTED MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;31m${message:$i:1}\033[0m"; done; echo -ne;
        printf "\n\t"
        message="> ABORTING MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;31m${message:$i:1}\033[0m"; done; echo -ne;
        git merge --abort &>/dev/null
        failureCount=$((failureCount+1))
    fi
    printf "\n"
done
printf "\n"
message="==========================="; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
message=">>> Number of successes: "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;32m${message:$i:1}\033[0m"; done; echo -ne;
message="$successCount"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
message=">>> Number of failures:  "; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "\033[1;31m${message:$i:1}\033[0m"; done; echo -ne;
message="$failureCount"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
message="==========================="; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
printf "\n"

# Switch back to main because it looks cleaner at the end
git checkout main &>/dev/null
message='Feature branch update complete!'; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;