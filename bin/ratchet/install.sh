#!/bin/sh
# Git directory
rootDir=$(git rev-parse --show-toplevel)
# Add to pre-commit workflow
sed -i '' 's/. "\$(dirname "\$0")\/husky.sh"/. "\$(dirname "\$0")\/ratchet.sh"\n. "\$(dirname "\$0")\/husky.sh"/g' $rootDir/.git/hooks/pre-commit
# move into hooks folder
cp $rootDir/bin/ratchet/ratchet.sh $rootDir/.git/hooks/ratchet.sh