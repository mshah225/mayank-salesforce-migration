set +e
curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":zap: Syncing Feature Branches","emoji":true}},{"type":"section","text":{"type":"mrkdwn","text":"*Notice:* This was automatically triggered by a push to `main` or manually run by a repository administrator."}},{"type":"section","text":{"type":"mrkdwn","text":"Please *do not* make any changes to feature branches until this is complete, and then make sure to update your local copy of the repository."}},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
git config pull.rebase false && git config user.name "GitHub Actions" && git config user.email "41898282+github-actions[bot]@users.noreply.github.com" && git fetch --prune &>/dev/null && git reset --hard origin/main &>/dev/null

deletedBranchCount=0
cleanMergeCount=0
abortedMergeCount=0
deletedBranchArray=()
cleanMergeArray=()
abortedMergeArray=()

for remote in $(git branch -r); do
    if [[ "$remote" != "origin/HEAD" ]] && [[ "$remote" != "->" ]] && [[ "$remote" != "origin/main" ]]; then
        branch="${remote#origin/}"
        git checkout $branch

        if [[ "$branch" == "sync" ]] || [[ "$branch" == "sync-pr" ]]; then
            git reset --hard origin/main
            git push -f origin $branch
            cleanMergeArray+=("$branch")
            cleanMergeCount=$((cleanMergeCount + 1))
            continue
        fi

        if git diff-index --quiet origin/main --; then
            sha=$(git rev-parse --short HEAD)
            git checkout -f main
            git branch -D $branch
            git push origin --delete $branch
            deletedBranchArray+=("$branch [$sha]")
            deletedBranchCount=$((deletedBranchCount + 1))
            continue
        fi

        git pull --no-edit origin main
        if [ $? -eq 0 ]; then
            git push origin $branch
            cleanMergeArray+=("$branch")
            cleanMergeCount=$((cleanMergeCount + 1))
        else
            git merge --abort
            abortedMergeArray+=("$branch")
            abortedMergeCount=$((abortedMergeCount + 1))
        fi

    fi
done

blocks='{
	"blocks": [
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": ":partywizard: Syncing Feature Branches [DONE]",
				"emoji": true
			}
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": "<!here|here>"
				}
			]
		},'

deletedBranchBlocks=''
if [ ${#deletedBranchArray[@]} -gt 0 ]; then
    deletedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":x: *deletes:* '"$deletedBranchCount"'"
				}
			]
		},
        {
            "type": "rich_text",
            "elements": [
                {
                    "type": "rich_text_list",
                    "elements": ['

    for index in "${!deletedBranchArray[@]}"; do
        branch="${deletedBranchArray[$index]}"
        deletedBranchBlocks=''"$deletedBranchBlocks"'{"type":"rich_text_section","elements":[{"type":"text","text":"'"$branch"'"}]},'
    done

    deletedBranchBlocks=''"$deletedBranchBlocks"'
                    ],
                    "style": "bullet",
                    "indent": 1
                }
            ]
        },'
else
    deletedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":x: *deletes:* '"$deletedBranchCount"'"
				},
			]
		},
        {
			"type": "section",
			"fields": [
                {
                    "type": "mrkdwn",
                    "text": "&nbsp;&nbsp;→ No branches to list."
                }
            ]
        },'
fi
blocks="$blocks$deletedBranchBlocks"

abortedMergeBlocks=''
if [ ${#abortedMergeArray[@]} -gt 0 ]; then
    abortedMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":exclamation: *aborted merges:* '"$abortedMergeCount"'"
				}
			]
		},
        {
            "type": "rich_text",
            "elements": [
                {
                    "type": "rich_text_list",
                    "elements": ['

    for index in "${!abortedMergeArray[@]}"; do
        branch="${abortedMergeArray[$index]}"
        abortedMergeBlocks=''"$abortedMergeBlocks"'{"type":"rich_text_section","elements":[{"type":"text","text":"'"$branch"'"}]},'
    done

    abortedMergeBlocks=''"$abortedMergeBlocks"'
                    ],
                    "style": "bullet",
                    "indent": 1
                }
            ]
        },'
else
    abortedMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":exclamation: *aborted merges:* '"$abortedMergeCount"'"
				}
			]
		},
        {
			"type": "section",
			"fields": [
                {
                    "type": "mrkdwn",
                    "text": "&nbsp;&nbsp;→ No branches to list."
                }
            ]
        },'
fi
blocks="$blocks$abortedMergeBlocks"

cleanMergeBlocks=''
if [ ${#cleanMergeArray[@]} -gt 0 ]; then
    cleanMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":canvas-check: *clean merges:* '"$cleanMergeCount"'"
				}
			]
		},
        {
            "type": "rich_text",
            "elements": [
                {
                    "type": "rich_text_list",
                    "elements": ['

    for index in "${!cleanMergeArray[@]}"; do
        branch="${cleanMergeArray[$index]}"
        cleanMergeBlocks=''"$cleanMergeBlocks"'{"type":"rich_text_section","elements":[{"type":"text","text":"'"$branch"'"}]},'
    done

    cleanMergeBlocks=''"$cleanMergeBlocks"'
                    ],
                    "style": "bullet",
                    "indent": 1
                }
            ]
        },'
else
    cleanMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":canvas-check: *clean merges:* '"$cleanMergeCount"'"
				},
			]
		},
        {
			"type": "section",
			"fields": [
                {
                    "type": "mrkdwn",
                    "text": "&nbsp;&nbsp;→ No branches to list."
                }
            ]
        },'
fi
blocks="$blocks$cleanMergeBlocks"

blocks=''"$blocks"'
    ]
}'

echo $blocks

curl -X POST -H "Content-type: application/json" --data "$blocks" https://hooks.slack.com/services/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
