import json
import os
import requests
from github import Github


def post_message_to_slack(blocks=None):
    slack_token = "xoxb-5106578285-2024746179665-6YM7l23Gti2SVlEGZivXUYH5"
    slack_channel = "#uto-salesforce-devs"
    return requests.post(
        "https://slack.com/api/chat.postMessage",
        {
            "token": slack_token,
            "channel": slack_channel,
            "blocks": json.dumps(blocks) if blocks else None,
        },
    ).json()


github = Github(os.getenv("github_token"))
repo = github.get_repo("ASU/crm-salesforce-enterprise")

if repo.name == "crm-salesforce-enterprise" and repo.owner.login == "ASU":
    for pull in repo.get_pulls():
        hasAliusedLabel = False
        hasReviewers = False
        reviewersString = ""
        headerMergeableEmoji = ""
        if pull.draft == False:
            for label in pull.labels:
                if label.name == "Aliused":
                    hasAliusedLabel = True
            if not hasAliusedLabel:
                requestedReviewers = pull.get_review_requests()[0]
                if requestedReviewers:
                    isFirstReviewer = True
                    for reviewer in requestedReviewers:
                        hasReviewers = True
                        login = reviewer.login
                        if requestedReviewers.totalCount == 1:
                            reviewersString = reviewersString + login
                        else:
                            if isFirstReviewer:
                                reviewersString = reviewersString + login
                                isFirstReviewer = False
                            else:
                                reviewersString = (
                                    reviewersString + ", " + reviewer.login
                                )
                if hasReviewers:
                    if pull.mergeable == True:
                        headerMergeableEmoji = ":git-pr-check-passed:"
                    else:
                        headerMergeableEmoji = ":git-pr-check-failed:"
                    blocks = [
                        {
                            "type": "header",
                            "text": {
                                "type": "plain_text",
                                "text": ":git-pr-opened: "
                                + pull.title
                                + " (#"
                                + str(pull.number)
                                + ") "
                                + headerMergeableEmoji,
                                "emoji": True,
                            },
                        },
                        {
                            "type": "section",
                            "fields": [
                                {
                                    "type": "mrkdwn",
                                    "text": "*Author*\n" + pull.user.login,
                                },
                                {
                                    "type": "mrkdwn",
                                    "text": "*Reviewers*\n" + reviewersString,
                                },
                            ],
                        },
                        {
                            "type": "section",
                            "fields": [
                                {
                                    "type": "mrkdwn",
                                    "text": "*Base branch*\n" + pull.base.label,
                                },
                                {
                                    "type": "mrkdwn",
                                    "text": "*Compare branch*\n" + pull.head.label,
                                },
                            ],
                        },
                        {
                            "type": "section",
                            "text": {
                                "type": "mrkdwn",
                                "text": "*Description*\n"
                                + str(pull.body)
                                + "\n\n"
                                + str(pull.html_url),
                            },
                        },
                    ]
                    response = json.loads(json.dumps(post_message_to_slack(blocks)))
                    if response["ok"] == True:
                        pull.add_to_labels("Aliused")
