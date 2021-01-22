#!/bin/bash

# Fetch and apply all branch updates
git fetch --all
hub sync

# Switch to master and update from origin
git checkout master
git pull origin master

# Check over all origin branches and track any new ones
for remote in `git branch -r`; do git branch --track ${remote#origin/} $remote; done

# Iterate over all branches and attempt to apply any new changes in master to the selected branch
for branch in $(git for-each-ref --format='%(refname:short)' --sort='*refname:short' refs/heads/); do
    git checkout $branch
    git pull --no-edit origin master
    if [ $? -eq 0 ]; then
        # Clean merge, proceed with pushing
        git push origin $branch
    else
        # Conflicted merge, abort and handle manually
        git merge --abort
    fi
done

# Switch back to master because it looks cleaner at the end
git checkout master