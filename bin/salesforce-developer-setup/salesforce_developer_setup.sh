#!/bin/bash

# Create progress spinner when waiting on a task
start_spinner() {
    echo -n "[SALESFORCE DEVELOPER SETUP] IN PROGRESS "
    spinner="/|\\-/|\\-"
    while :; do
        for i in $(seq 0 7); do
            echo -n "${spinner:$i:1}"
            echo -en "\010"
            sleep 1
        done
    done
}

reset && reset

# Start spinner while waiting for tasks to finish
start_spinner &
SPIN_PID=$!
trap "kill -9 $SPIN_PID" $(seq 0 15)

# Ensure that ASU is set as a remote
git remote add ASU https://github.com/ASU/crm-salesforce-enterprise &>/dev/null

# Keep Homebrew up-to-date
if [ "$(uname)" == "Darwin" ]; then
    brew update &>/dev/null
    brew upgrade &>/dev/null
fi

# Keep npm up-to-date
npm list --location=global | grep sfdx-cli &>/dev/null || npm install --location=global sfdx-cli &>/dev/null
npm list --location=global | grep prettier &>/dev/null || npm install --location=global -D -E prettier &>/dev/null
npm list --location=global | grep prettier-plugin-apex &>/dev/null || npm install --location=global -D -E prettier-plugin-apex &>/dev/null
npm list | grep prettier &>/dev/null || npm install --save-dev --save-exact prettier &>/dev/null
npm list | grep prettier-plugin-apex &>/dev/null || npm install --save-dev --save-exact prettier-plugin-apex &>/dev/null
npm list | grep eslint &>/dev/null || npm install --save-dev eslint &>/dev/null
npm list | grep @babel/core &>/dev/null || npm install --save-dev @babel/core &>/dev/null
npm list | grep @babel/eslint-parser &>/dev/null || npm install --save-dev @babel/eslint-parser &>/dev/null
npm list | grep @lwc/eslint-plugin-lwc &>/dev/null || npm install --save-dev @lwc/eslint-plugin-lwc &>/dev/null
npm list | grep @salesforce/eslint-plugin-aura &>/dev/null || npm install --save-dev @salesforce/eslint-plugin-aura &>/dev/null
npm list | grep husky &>/dev/null && [ $? -eq 0 ] && npm uninstall husky &>/dev/null && npm install -D husky@4 &>/dev/null || npm install -D husky@4 &>/dev/null
npm update &>/dev/null
npm update --location=global &>/dev/null

# Force Visual Studio Code to install or update the extensions
code --install-extension salesforce.salesforcedx-vscode --force &>/dev/null
code --install-extension dbaeumer.vscode-eslint --force &>/dev/null
code --install-extension esbenp.prettier-vscode --force &>/dev/null
code --install-extension fabiospampinato.vscode-commands --force &>/dev/null
code --install-extension fabiospampinato.vscode-terminals --force &>/dev/null
code --install-extension ms-python.python --force &>/dev/null
code --install-extension ms-python.black-formatter --force &>/dev/null
code --install-extension foxundermoon.shell-format --force &>/dev/null

# Install ratchet script
./../ratchet/install.sh

reset && exit
