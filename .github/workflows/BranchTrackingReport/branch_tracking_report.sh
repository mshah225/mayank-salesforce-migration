set -xe
cd $GITHUB_WORKSPACE/wiki

# Count the nunber of JSON elements per variable
all_branches_count=$(jq length <<<"$ALL_BRANCHES")
dev_branches_count=$(jq length <<<"$DEV_BRANCHES")
qa_branches_count=$(jq length <<<"$QA_BRANCHES")
uat_branches_count=$(jq length <<<"$UAT_BRANCHES")

all_branches_to_report=()
dev_branches_to_report=()
qa_branches_to_report=()
uat_branches_to_report=()

# If JSON elements exists, then store them
for ((i = 0; i < all_branches_count; i++)); do
    branch=$(jq -r ".[$i]" <<<"$ALL_BRANCHES")
    all_branches_to_report+=("$branch")
done

for ((i = 0; i < dev_branches_count; i++)); do
    branch=$(jq -r ".[$i]" <<<"$DEV_BRANCHES")
    dev_branches_to_report+=("$branch")
done

for ((i = 0; i < qa_branches_count; i++)); do
    branch=$(jq -r ".[$i]" <<<"$QA_BRANCHES")
    qa_branches_to_report+=("$branch")
done

for ((i = 0; i < uat_branches_count; i++)); do
    branch=$(jq -r ".[$i]" <<<"$UAT_BRANCHES")
    uat_branches_to_report+=("$branch")
done

# Create a hash to compare to later (to see if we actually need to update the file)
old_file_hash=$(md5sum Branch-Tracking-Report.md)
rm -f Branch-Tracking-Report.md
(
    for i in $(find . -name 'Branch-Tracking-Report.md'); do
        filename=$(basename $i)
        filename=${filename/.md/}
        cat $i |
            # print everything after this point in the markdown
            sed -n -e '/## LAST PARAGRAPH TITLE/,$p' |
            # replace title with name of the file
            sed -e 's@^## LAST PARAGRAPH TITLE@## '"$filename"'@'

        echo "### [Branches merged into dev]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/tree/dev)"
        if [ ${#dev_branches_to_report[@]} -gt 0 ]; then
            for index in "${!dev_branches_to_report[@]}"; do
                branch="${dev_branches_to_report[$index]}"
                echo "* $branch"
            done
        else
            echo '* NONE'
        fi
        echo '---'

        echo "### [Branches merged into qa]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/tree/qa)"
        if [ ${#qa_branches_to_report[@]} -gt 0 ]; then
            for index in "${!qa_branches_to_report[@]}"; do
                branch="${qa_branches_to_report[$index]}"
                echo "* $branch"
            done
        else
            echo '* NONE'
        fi
        echo '---'

        echo "### [Branches merged into uat]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/tree/uat)"
        if [ ${#uat_branches_to_report[@]} -gt 0 ]; then
            for index in "${!uat_branches_to_report[@]}"; do
                branch="${uat_branches_to_report[$index]}"
                echo "* $branch"
            done
        else
            echo '* NONE'
        fi
        echo '---'

        echo "### [Branches à la carte]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/branches)"
        if [ ${#all_branches_to_report[@]} -gt 0 ]; then
            for index in "${!all_branches_to_report[@]}"; do
                core_branches=" "
                branch="${all_branches_to_report[$index]}"
                IFS=':' read -ra branch_details <<<"$branch"

                for i in "${!branch_details[@]}"; do
                    if [[ $i == 0 ]]; then
                        branch="${branch_details[$i]}"
                    elif [[ $i == 1 ]]; then
                        core_branch_details="${branch_details[$i]}"
                        if [[ "$core_branch_details" =~ "none" ]]; then
                            core_branches=""
                        elif [[ "$core_branch_details" =~ "," ]]; then
                            IFS=',' read -ra branch_detail <<<"$core_branch_details"
                            for j in "${!branch_detail[@]}"; do
                                core_branch="${branch_detail[$j]}"
                                if [[ $j == 0 ]]; then
                                    core_branches+="&rarr; $core_branch"
                                else
                                    core_branches+=", $core_branch"
                                fi
                            done
                        else
                            core_branches+="&rarr; $core_branch_details"
                        fi
                    fi
                done

                echo "* $branch$core_branches"
            done
        else
            echo '* NONE'
        fi
    done
) >Branch-Tracking-Report.md
new_file_hash=$(md5sum Branch-Tracking-Report.md)

if [ "$old_file_hash" != "$new_file_hash" ]; then
    echo '[[ NEW CHANGES TO FILE ]]'
    git config pull.rebase false
    git config user.name "GitHub Actions"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git add Branch-Tracking-Report.md
    git commit -m "Update Branch Tracking Report at $(date)"
    git push origin master

    curl -X POST -H 'Content-type: application/json' --data '{"blocks":[{"type":"header","text":{"type":"plain_text","text":":newspaper: Updated Branch Tracking Report","emoji":true}},{"type":"section","text":{"type":"mrkdwn","text":"A new branch tracking report was posted to <https://github.com/ASU/crm-salesforce-enterprise/wiki/Branch-Tracking-Report|our repository wiki>."}},{"type":"section","text":{"type":"mrkdwn","text":"<!here|here>"}}]}' https://hooks.slack.com/services/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
else
    echo '[[ NO CHANGES TO FILE ]]'
fi
