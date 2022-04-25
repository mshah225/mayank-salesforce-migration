#!/bin/sh
err=""
fileList=()

main() {
    rootDir=$(git rev-parse --show-toplevel) # root git directory
    # fileList = all changed files
    filesToCheckStrRelative=$(git diff --name-only --cached)
    for fileName in $filesToCheckStrRelative; do
        fileList+=("$rootDir/$fileName")
    done
    # scan to see if an illegal term appears (only check against changed files)
    illegalTermsStr=$(cat $rootDir/bin/ratchet/ratchet.txt) # the file containing the illegal strings and their counts
    IFS=$'\n' read -rd '' -a illegalTerms <<< "$illegalTermsStr"
    foundTerm=""
    for row in $illegalTerms; do
        IFS=$':' read -rd '' -a rowArr <<< "$row" #Splits row by :
        term=${rowArr[0]} # before : is the term
        expectedCount=$(echo "${rowArr[1]}") # after : is the expected count
        actualCount=$(checkFilesForTerm "$term") # how many times does it actually appear?
        if [ "$actualCount" -gt "0" ]; then
            foundTerm=$row
            break
        fi
    done

    # do a full scan to check occurence count if an illegal term did appear
    if [ "$foundTerm" != "" ]; then
        # fileList = all Apex classes
        fileList=()
        IFS=$'\n' read -rd '' -a fileList <<< "$(ls $rootDir/force-app/main/default/classes/*.cls)"
        IFS=$':' read -rd '' -a rowArr <<< "$foundTerm" #Splits row by :
        term=${rowArr[0]} # before : is the term
        expectedCount=$(echo "${rowArr[1]}") # after : is the expected count
        actualCount=$(checkFilesForTerm "$term") # how many times does it actually appear?
        echo "[term] $term"
        echo "[expectedCount] $expectedCount"
        echo "[actualCount] $actualCount"
        if [ "$actualCount" -gt "$expectedCount" ]; then
            err="\033[31mYou have used $term!\nExpected, at most $expectedCount instances of \"$term\", but found $actualCount\n$term is a deprecated component, and it seems you have increased it usage.  You should consider if this is really what you want to do.\nIf it is, you should modify the rachet.txt file to increase the limit of occurences for $term.\nBut, more likely, you should change your code to not use $term.\033[0m"
            foundTerm=$term
            break
        fi

    fi

    if [ "$err" != "" ]; then
        >&2 echo "$err"
        exit 1
    fi
}

# Check every file for a specifc term 
checkFilesForTerm() {
    filesArr=${fileList[@]}
    searchTerm=$1
    totalCount=0
    for fileName in $filesArr; do
        countInThisFile="$(checkFileForTerm "$fileName" "$searchTerm")"
        totalCount="$(($totalCount+$countInThisFile))"
    done
    echo "$totalCount"
}

# Check a single file for a specific term
checkFileForTerm() {
    filepath=$1
    searchTerm=$2
    num="$(grep -o "$searchTerm" "$filepath" | wc -l | tr -d ' ')"
    echo "$num"
}

main # call main function