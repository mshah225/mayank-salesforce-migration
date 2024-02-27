set +e
curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":sync: Syncing Feature Branches","emoji":true}},{"type":"section","text":{"type":"mrkdwn","text":"This was automatically triggered by a push to the primary branch or manually run by a repository administrator. Please *do not* make any changes to feature branches until this is complete, and then make sure to update your local copy of the repository. Last known HEAD commit SHAs are provided next to branch names within brackets."}},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
git config pull.rebase false && git config user.name "GitHub Actions" && git config user.email "41898282+github-actions[bot]@users.noreply.github.com" && git fetch --prune &>/dev/null && git reset --hard origin/main &>/dev/null

deletedBranchCount=0
cleanMergeCount=0
cleanMergeCoreCount=0
abortedMergeCount=0
abortedMergeCoreCount=0
deletedBranchArray=()
cleanMergeArray=()
cleanMergeCoreArray=()
abortedMergeArray=()
abortedMergeCoreArray=()
dev="dev"
qa="qa"
uat="uat"
wpc="wpc"

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

		# Reset sync and sync-pr branches back to the same state as main
		if [[ "$branch" == "sync" ]] || [[ "$branch" == "sync-pr" ]]; then
			git reset --hard origin/main
			git push -f origin $branch
			cleanMergeArray+=("$branch [$sha]")
			cleanMergeCount=$((cleanMergeCount + 1))
			continue
		fi

		# IF the branch contains no file changes compared to main, delete it
		# ELSE attempt to update the branch, but abort if necessary
		if git diff-index --quiet origin/main --; then
			git checkout -f main
			git branch -D $branch
			git push origin --delete $branch
			deletedBranchArray+=("$branch [$sha]")
			deletedBranchCount=$((deletedBranchCount + 1))
		else
			git pull --no-edit origin main
			if [ $? -eq 0 ]; then
				git push origin $branch
				if [[ "$branch" == "dev" ]] || [[ "$branch" == "qa" ]] || [[ "$branch" == "uat" ]] || [[ "$branch" == "wpc" ]]; then
					cleanMergeCoreArray+=("$branch [$sha]")
					cleanMergeCoreCount=$((cleanMergeCoreCount + 1))
				else
					cleanMergeArray+=("$branch [$sha]")
					cleanMergeCount=$((cleanMergeCount + 1))
				fi
			else
				git merge --abort
				if [[ "$branch" == "dev" ]] || [[ "$branch" == "qa" ]] || [[ "$branch" == "uat" ]] || [[ "$branch" == "wpc" ]]; then
					abortedMergeCoreArray+=("$branch [$sha]")
					abortedMergeCoreCount=$((abortedMergeCoreCount + 1))
				else
					abortedMergeArray+=("$branch [$sha]")
					abortedMergeCount=$((abortedMergeCount + 1))
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
				"text": ":verified-badge: Feature Branch Sync Results",
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
					"text": ":code-brackets: *CORE BRANCHES PASSING:* '"$cleanMergeCoreCount"' of 4"
				}
			]
		},'

devBranchBlocks=''
if [[ "${cleanMergeCoreArray[*]}" =~ "${dev}" ]]; then
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
if [[ "${cleanMergeCoreArray[*]}" =~ "${qa}" ]]; then
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
if [[ "${cleanMergeCoreArray[*]}" =~ "${uat}" ]]; then
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
if [[ "${cleanMergeCoreArray[*]}" =~ "${wpc}" ]]; then
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

abortedMergeBlocks=''
if [ ${#abortedMergeArray[@]} -gt 0 ]; then
	abortedMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":warning-badge: *ABORTED MERGES:* '"$abortedMergeCount"'"
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
        },
        {
			"type": "divider"
		},'
else
	abortedMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":warning-badge: *ABORTED MERGES:* '"$abortedMergeCount"'"
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
blocks="$blocks$abortedMergeBlocks"

cleanMergeBlocks=''
if [ ${#cleanMergeArray[@]} -gt 0 ]; then
	cleanMergeBlocks='
        {
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": ":checkmark: *CLEAN MERGES:* '"$cleanMergeCount"'"
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
					"text": ":checkmark: *CLEAN MERGES:* '"$cleanMergeCount"'"
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
        },'
fi
blocks="$blocks$cleanMergeBlocks"

blocks=''"$blocks"'
    ]
}'

echo $blocks

curl -X POST -H "Content-type: application/json" --data "$blocks" https://hooks.slack.com/services/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
