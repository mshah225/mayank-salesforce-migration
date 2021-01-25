#!/bin/bash

# Fetch and apply all branch updates
echo -ne "Fetching all branch updates........... "
git fetch --all &>/dev/null
echo "Fetched."
echo -ne "Syncing all branch updates........... "
hub sync &>/dev/null
echo "Synced."

# Switch to master and update from origin
echo -ne "Updating master from remote origin........... "
git checkout master &>/dev/null
git pull origin master &>/dev/null
echo "Updated."

# Check over all origin branches and track any new ones
echo -ne "Tracking new remote origin branches........... "
for remote in `git branch -r`; do 
    git branch --track ${remote#origin/} $remote &>/dev/null
done
echo "Tracked."

# Iterate over all branches and attempt to apply any new changes in master to the selected branch
echo "Applying changes to clean branches........... "
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    echo -ne "...Checking out $branch..."
    git checkout $branch &>/dev/null
    echo -ne "...Pulling updates for $branch..."
    git pull --no-edit origin master &>/dev/null
    if [ $? -eq 0 ]; then
        # Clean merge, proceed with pushing
        echo -ne "...Clean merge..."
        echo -ne "...Pushing any available updates to $branch..."
        git push origin $branch &>/dev/null
    else
        # Conflicted merge, abort and handle manually
        echo -ne "...Conflicted merge..."
        echo -ne "...Aborting merge for $branch..."
        git merge --abort &>/dev/null
    fi
    echo ""
done
echo "Applied changes to all clean branches."

# Switch back to master because it looks cleaner at the end
git checkout master &>/dev/null
echo "Feature branch update complete!"