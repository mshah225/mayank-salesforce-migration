set +e
curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":sync: Evaluating Upstream Mergeability","emoji":true}},{"type":"section","text":{"type":"mrkdwn","text":"This was automatically triggered by a push to the primary branch or manually run by a repository administrator. Please *do not* make any changes to feature branches until this is complete, and then make sure to check the *CONFLICTS* section for any relevant branches that should be fixed. Last known HEAD commit SHAs are provided next to branch names within brackets."}},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
git config pull.rebase false && git config user.name "GitHub Actions" && git config user.email "41898282+github-actions[bot]@users.noreply.github.com" && git fetch --prune &>/dev/null && git reset --hard origin/main &>/dev/null

deletedBranchCount=0
mergeableCoreBranchCount=0
conflictedBranchCount=0
conflictedCoreBranchCount=0
deletedBranchArray=()
mergeableCoreBranchArray=()
conflictedBranchArray=()
conflictedCoreBranchArray=()

dev="dev"
qa="qa"
uat="uat"
wpc="wpc"

coreBranches=("$dev" "$qa" "$uat" "$wpc")
coreBranchesCount="${#coreBranches[@]}"

for remote in $(git branch -r); do
	if [[ "$remote" != "origin/HEAD" ]] && [[ "$remote" != "->" ]] && [[ "$remote" != "origin/main" ]]; then
		# Determine branch name and checkout said branch
		branch="${remote#origin/}"
		git checkout $branch

		# Define the current SHA prior to making changes otherwise it's not useful
		sha=$(git rev-parse --short HEAD)

		# Branches to ignore
		if [[ "$branch" == "wpc-config" ]]; then
			continue
		fi

		# Reset sync and prod branches back to the same state as main
		if [[ "$branch" == "sync" ]] || [[ "$branch" == "prod" ]]; then
			git reset --hard origin/main
			git push -f origin $branch
			continue
		fi

		# IF the branch contains no file changes compared to main, delete it
		# ELSE if it's a core branch, attempt to update the branch
		# ELSE if it's not a core branch, only report if it has conflicts
		if git diff-index --quiet origin/main --; then
			git checkout -f main
			git branch -D $branch
			git push origin --delete $branch
			deletedBranchArray+=("$branch [$sha]")
			deletedBranchCount=$((deletedBranchCount + 1))
		else
			git pull --no-edit origin main
			if [ $? -eq 0 ]; then
				if [[ "$branch" == "dev" ]] || [[ "$branch" == "qa" ]] || [[ "$branch" == "uat" ]] || [[ "$branch" == "wpc" ]]; then
					git push origin $branch
					mergeableCoreBranchArray+=("$branch")
					mergeableCoreBranchCount=$((mergeableCoreBranchCount + 1))
				fi
			else
				git merge --abort
				if [[ "$branch" == "dev" ]] || [[ "$branch" == "qa" ]] || [[ "$branch" == "uat" ]] || [[ "$branch" == "wpc" ]]; then
					conflictedCoreBranchArray+=("$branch")
					conflictedCoreBranchCount=$((conflictedCoreBranchCount + 1))
				else
					conflictedBranchArray+=("$branch")
					conflictedBranchCount=$((conflictedBranchCount + 1))
				fi
			fi
		fi
	fi
done

blocks='{
	"blocks": [
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": ":verified-badge: Branch Status Report",
				"emoji": true
			}
		},
        {
			"type": "divider"
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":code-brackets: *CORE BRANCHES PASSING:* '"$mergeableCoreBranchCount"' of '"$coreBranchesCount"'"
				}
			]
		},'

devBranchBlocks=''
if [[ "${mergeableCoreBranchArray[*]}" =~ "${dev}" ]]; then
	devBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *dev*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":canvas-check: PASSING",
					"emoji": true
				},
				"value": "dev",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/dev",
				"action_id": "button-action"
			}
		},'
else
	devBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *dev*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":exclamation: FAILING",
					"emoji": true
				},
				"value": "dev",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/dev",
				"action_id": "button-action"
			}
		},'
fi
blocks="$blocks$devBranchBlocks"

qaBranchBlocks=''
if [[ "${mergeableCoreBranchArray[*]}" =~ "${qa}" ]]; then
	qaBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *qa*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":canvas-check: PASSING",
					"emoji": true
				},
				"value": "qa",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/qa",
				"action_id": "button-action"
			}
		},'
else
	qaBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *qa*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":exclamation: FAILING",
					"emoji": true
				},
				"value": "qa",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/qa",
				"action_id": "button-action"
			}
		},'
fi
blocks="$blocks$qaBranchBlocks"

uatBranchBlocks=''
if [[ "${mergeableCoreBranchArray[*]}" =~ "${uat}" ]]; then
	uatBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *uat*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":canvas-check: PASSING",
					"emoji": true
				},
				"value": "uat",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/uat",
				"action_id": "button-action"
			}
		},'
else
	uatBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *uat*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":exclamation: FAILING",
					"emoji": true
				},
				"value": "uat",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/uat",
				"action_id": "button-action"
			}
		},'
fi
blocks="$blocks$uatBranchBlocks"

wpcBranchBlocks=''
if [[ "${mergeableCoreBranchArray[*]}" =~ "${wpc}" ]]; then
	wpcBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *wpc*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":canvas-check: PASSING",
					"emoji": true
				},
				"value": "wpc",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/wpc",
				"action_id": "button-action"
			}
		},
        {
			"type": "divider"
		},'
else
	wpcBranchBlocks='
        {
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "→ *wpc*"
			},
			"accessory": {
				"type": "button",
				"text": {
					"type": "plain_text",
					"text": ":exclamation: FAILING",
					"emoji": true
				},
				"value": "wpc",
				"url": "https://github.com/ASU/crm-salesforce-enterprise/tree/wpc",
				"action_id": "button-action"
			}
		},
        {
			"type": "divider"
		},'
fi
blocks="$blocks$wpcBranchBlocks"

deletedBranchBlocks=''
if [ ${#deletedBranchArray[@]} -gt 0 ]; then
	deletedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":crossmark: *DELETES:* '"$deletedBranchCount"'"
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
        },
        {
			"type": "divider"
		},'
else
	deletedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":crossmark: *DELETES:* '"$deletedBranchCount"'"
				},
			]
		},
        {
			"type": "section",
			"fields": [
                {
                    "type": "mrkdwn",
                    "text": "  → No branches to list."
                }
            ]
        },
        {
			"type": "divider"
		},'
fi
blocks="$blocks$deletedBranchBlocks"

conflictedBranchBlocks=''
if [ ${#conflictedBranchArray[@]} -gt 0 ]; then
	conflictedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":warning-badge: *BRANCHES OF SHAME:* '"$conflictedBranchCount"'"
				}
			]
		},
        {
            "type": "rich_text",
            "elements": [
                {
                    "type": "rich_text_list",
                    "elements": ['

	for index in "${!conflictedBranchArray[@]}"; do
		branch="${conflictedBranchArray[$index]}"
		conflictedBranchBlocks=''"$conflictedBranchBlocks"'{"type":"rich_text_section","elements":[{"type":"text","text":"'"$branch"'"}]},'
	done

	conflictedBranchBlocks=''"$conflictedBranchBlocks"'
                    ],
                    "style": "bullet",
                    "indent": 1
                }
            ]
        },
        {
			"type": "divider"
		},'
else
	conflictedBranchBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":warning-badge: *ABORTED MERGES:* '"$conflictedBranchCount"'"
				}
			]
		},
        {
			"type": "section",
			"fields": [
                {
                    "type": "mrkdwn",
                    "text": "  → No branches to list."
                }
            ]
        },
        {
			"type": "divider"
		},'
fi
blocks="$blocks$conflictedBranchBlocks"

blocks=''"$blocks"'
    ]
}'

echo $blocks

curl -X POST -H "Content-type: application/json" --data "$blocks" https://hooks.slack.com/services/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
