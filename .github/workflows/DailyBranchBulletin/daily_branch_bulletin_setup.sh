set +e && git config pull.rebase false && git config user.name "GitHub Actions" && git config user.email "41898282+github-actions[bot]@users.noreply.github.com" && git fetch --prune &>/dev/null && git reset --hard origin/main &>/dev/null

git_branch_is_merged() {
    merge_destination_branch=$1
    merge_source_branch=$2

    merge_base=$(git merge-base $merge_destination_branch $merge_source_branch)
    merge_source_current_commit=$(git rev-parse $merge_source_branch)
    if [[ $merge_base = $merge_source_current_commit ]]; then
        echo "--> $merge_source_branch is merged into $merge_destination_branch"
        return 0
    else
        echo "--> $merge_source_branch is not merged into $merge_destination_branch"
        return 1
    fi
}

all_branches=()
dev_branches=()
qa_branches=()
uat_branches=()

for remote in $(git branch -r); do
    if [[ "$remote" != "origin/HEAD" ]] && [[ "$remote" != "->" ]] && [[ "$remote" != "origin/main" ]]; then
        branch="${remote#origin/}"

        if [[ "$branch" != "dev" ]] && [[ "$branch" != "qa" ]] && [[ "$branch" != "uat" ]] && [[ "$branch" != "sync" ]] && [[ "$branch" != "sync-pr" ]]; then
            git checkout $branch

            # Determine if the source branch has been merged into dev
            # If yes, keep track of the branch
            is_merged_into_dev=$(git_branch_is_merged "dev" "$branch")
            if [ $is_merged_into_dev -eq 0 ]; then
                is_merged_into_dev="true"
                dev_branches+=("$branch")
            else
                is_merged_into_dev="false"
            fi

            # Determine if the source branch has been merged into qa
            # If yes, keep track of the branch
            is_merged_into_qa=$(git_branch_is_merged "qa" "$branch")
            if [ $is_merged_into_qa -eq 0 ]; then
                is_merged_into_qa="true"
                qa_branches+=("$branch")
            else
                is_merged_into_qa="false"
            fi

            # Determine if the source branch has been merged into uat
            # If yes, keep track of the branch
            is_merged_into_uat=$(git_branch_is_merged "uat" "$branch")
            if [ $is_merged_into_uat -eq 0 ]; then
                is_merged_into_uat="true"
                uat_branches+=("$branch")
            else
                is_merged_into_uat="false"
            fi

            # Determine if the source branch is completely unmerged into dev, qa & uat
            # If there is a valid merge, keep track of which branches have been merged into the core branches at a higher level
            if [[ $is_merged_into_dev == "false" ]] && [[ $is_merged_into_qa == "false" ]] && [[ $is_merged_into_uat == "false" ]]; then
                all_branches+=("$branch:none")
            else
                merged_branches=()
                merged_branches_string=""
                delimiter=""

                if [[ ${dev_branches[@]} =~ $branch ]]; then
                    merged_branches+=("dev")
                fi

                if [[ ${qa_branches[@]} =~ $branch ]]; then
                    merged_branches+=("qa")
                fi

                if [[ ${uat_branches[@]} =~ $branch ]]; then
                    merged_branches+=("uat")
                fi

                for core_branch in "${merged_branches[@]}"; do
                    merged_branches_string="$merged_branches_string$delimiter$core_branch"
                    delimiter=","
                done

                all_branches+=("$branch:$merged_branches_string")
            fi

        fi

    fi
done

# FOR TESTING
# all_branches=('SFE-00000:dev,qa' 'SFE-00001:dev' 'SFE-00002:dev,qa' 'SFE-00003:dev,uat' 'SFE-00004:dev,uat')
# dev_branches=('SFE-00000' 'SFE-00001' 'SFE-00002' 'SFE-00003' 'SFE-00004')
# qa_branches=('SFE-00000' 'SFE-00002')
# uat_branches=('SFE-00003' 'SFE-00004')

all_branches=$(jq --compact-output --null-input '$ARGS.positional' --args -- "${all_branches[@]}")
dev_branches=$(jq --compact-output --null-input '$ARGS.positional' --args -- "${dev_branches[@]}")
qa_branches=$(jq --compact-output --null-input '$ARGS.positional' --args -- "${qa_branches[@]}")
uat_branches=$(jq --compact-output --null-input '$ARGS.positional' --args -- "${uat_branches[@]}")

echo "ALL_BRANCHES=$all_branches" >>"$GITHUB_ENV"
echo "DEV_BRANCHES=$dev_branches" >>"$GITHUB_ENV"
echo "QA_BRANCHES=$qa_branches" >>"$GITHUB_ENV"
echo "UAT_BRANCHES=$uat_branches" >>"$GITHUB_ENV"
