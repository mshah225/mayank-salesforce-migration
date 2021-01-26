#!/bin/bash

# Completely necessary narrative to begin script
reset
message="Hello there, traveler."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo -ne;
sleep 1
message=" I'm Alius."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="You look as though you have wondrous tales to share."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="Unfortunately, I was not created with the ability to listen to them."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="I trust that you have not come with devious intent."; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
sleep 1
message="Shall we begin? (y/n) "; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo -ne;

read input
if [ "$input" = "Y" ] || [ "$input" = "y" ] || [ "$input" = "yes" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ]; then
    message='Our code savior lives!'; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
    sleep 1
    reset
else
    message='I have no time for hooligans. Be gone!'; for ((i=0; i<${#message}; i++)); do echo "after 30" | tclsh; printf "${message:$i:1}"; done; echo;
    sleep 1
    return
fi

# Fetch and apply all branch updates
message="Fetching all branch updates..................."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
git fetch --all &>/dev/null
message=" Fetched."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
message="Syncing all branch updates...................."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
hub sync &>/dev/null
message=" Synced."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;

# Switch to master and update from origin
message="Updating master from remote origin............"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
git checkout master &>/dev/null
git pull origin master &>/dev/null
message=" Updated."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;

# Check over all origin branches and track any new ones
message="Tracking new remote origin branches..........."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
for remote in `git branch -r`; do 
    git branch --track ${remote#origin/} $remote &>/dev/null
done
message=" Tracked."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;

# Iterate over all branches and attempt to apply any new changes in master to the selected branch
message="Attempting changes............................"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    message=">> Checking out $branch"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
    git checkout $branch &>/dev/null
    printf "\n\t"
    message="> PULLING UPDATES"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
    git pull --no-edit origin master &>/dev/null
    if [ $? -eq 0 ]; then
        # Clean merge, proceed with pushing
        printf "\n\t"
        message="> CLEAN MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
        printf "\n\t"
        message="> PUSHING UPDATES"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
        git push origin $branch &>/dev/null
    else
        # Conflicted merge, abort and handle manually
        printf "\n\t"
        message="> CONFLICTED MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
        printf "\n\t"
        message="> ABORTING MERGE"; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo -ne;
        git merge --abort &>/dev/null
    fi
    printf "\n"
done
message="Applied changes to all clean branches."; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;

# Switch back to master because it looks cleaner at the end
git checkout master &>/dev/null
message='Feature branch update complete!'; for ((i=0; i<${#message}; i++)); do echo "after 5" | tclsh; printf "${message:$i:1}"; done; echo;