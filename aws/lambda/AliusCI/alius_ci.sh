function handler() {
    EVENT_DATA=$1

    set +e
    curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":zap: Starting an Alius CI run","emoji":true}},{"type":"section","text":{"type":"mrkdwn","text":"*Notice:* This was automatically triggered by a push to `ASU:main` or manually run by a repository administrator."}},{"type":"section","text":{"type":"mrkdwn","text":"Please *do not* make any changes to feature branches until this is complete, and then make sure to update your local copy of the repository. Alius processes roughly 25 branches per minute."}},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
    cd /tmp && git clone https://GITHUB_USERNAME:ghp_TOKEN@github.com/ASU/crm-salesforce-enterprise && cd crm-salesforce-enterprise && git config pull.rebase false && git config user.email "alius@asu.edu" && git config user.name "Alius CI" && git fetch --prune &>/dev/null

    cleanMergeCount=0
    abortedMergeCount=0

    cleanMergeArray=()
    abortedMergeArray=()

    cleanBranchText=""
    abortedBranchText=""

    for remote in $(git branch -r); do
        if [[ "$remote" != "origin/HEAD" ]] && [[ "$remote" != "->" ]] && [[ "$remote" != "origin/main" ]]; then
            git branch --track $remote &>/dev/null
            branch="${remote#origin/}"
            git checkout $branch &>/dev/null

            git pull --no-edit origin main &>/dev/null
            if [ $? -eq 0 ]; then
                git push origin $branch &>/dev/null
                cleanMergeArray+=("$branch")
                cleanMergeCount=$((cleanMergeCount + 1))
            else
                git merge --abort &>/dev/null
                if [[ "$branch" == "sync" ]] || [[ "$branch" == "sync-pr" ]]; then
                    git reset --hard origin/main &>/dev/null
                    git push -f origin $branch &>/dev/null
                    cleanMergeArray+=("$branch")
                    cleanMergeCount=$((cleanMergeCount + 1))
                else
                    abortedMergeArray+=("$branch")
                    abortedMergeCount=$((abortedMergeCount + 1))
                fi
            fi

        fi
    done

    for value in "${cleanMergeArray[@]}"; do
        cleanBranchText="$cleanBranchText- $value\n"
    done

    for value in "${abortedMergeArray[@]}"; do
        abortedBranchText="$abortedBranchText- $value\n"
    done

    curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":partywizardasu: Finished an Alius CI run","emoji":true}},{"type":"section","fields":[{"type":"mrkdwn","text":":canvas-check: *merges:* '"$cleanMergeCount"'"},{"type":"mrkdwn","text":":x: *merges:* '"$abortedMergeCount"'"}]},{"type":"section","fields":[{"type":"mrkdwn","text":"'"$cleanBranchText"'"},{"type":"mrkdwn","text":"'"$abortedBranchText"'"}]},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
}
