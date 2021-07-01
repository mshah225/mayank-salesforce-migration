#!/bin/bash

# Create progress spinner when waiting on a task
start_spinner() {
    spinner="/|\\-/|\\-"
    while :; do
        for i in $(seq 0 7); do
            echo -n "${spinner:$i:1}"
            echo -en "\010"
            sleep 1
        done
    done
}

reset
echo "███████ ████████  █████  ██████  ████████ ██ ███    ██  ██████      ███████ ███████ ████████ ██    ██ ██████      "
echo "██         ██    ██   ██ ██   ██    ██    ██ ████   ██ ██           ██      ██         ██    ██    ██ ██   ██     "
echo "███████    ██    ███████ ██████     ██    ██ ██ ██  ██ ██   ███     ███████ █████      ██    ██    ██ ██████      "
echo "     ██    ██    ██   ██ ██   ██    ██    ██ ██  ██ ██ ██    ██          ██ ██         ██    ██    ██ ██          "
echo "███████    ██    ██   ██ ██   ██    ██    ██ ██   ████  ██████      ███████ ███████    ██     ██████  ██ ██ ██ ██ "
sleep 3
reset

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
npm update &>/dev/null
npm install &>/dev/null
npm install -g sfdx-cli &>/dev/null
npm install --save-dev --save-exact prettier prettier-plugin-apex &>/dev/null
npm config set prefix /usr/local &>/dev/null
npm install -g -D -E prettier prettier-plugin-apex &>/dev/null
npm install eslint @babel/core @babel/eslint-parser @lwc/eslint-plugin-lwc --save-dev &>/dev/null
npm install --save-dev @salesforce/eslint-plugin-aura &>/dev/null
npm uninstall husky &>/dev/null
npm install -D husky@4 &>/dev/null

# Force Visual Studio Code to install or update the extensions
code --install-extension salesforce.salesforcedx-vscode --force &>/dev/null
code --install-extension dbaeumer.vscode-eslint --force &>/dev/null
code --install-extension esbenp.prettier-vscode --force &>/dev/null
code --install-extension fabiospampinato.vscode-commands --force &>/dev/null
code --install-extension fabiospampinato.vscode-terminals --force &>/dev/null
code --install-extension ms-python.python --force &>/dev/null

echo " ██████ ██       ██████  ███████ ██ ███    ██  ██████      ██ ███    ██     ██████   ██████      ███████ ███████  ██████  ██████  ███    ██ ██████  ███████    "
echo "██      ██      ██    ██ ██      ██ ████   ██ ██           ██ ████   ██          ██ ██  ████     ██      ██      ██      ██    ██ ████   ██ ██   ██ ██         "
echo "██      ██      ██    ██ ███████ ██ ██ ██  ██ ██   ███     ██ ██ ██  ██      █████  ██ ██ ██     ███████ █████   ██      ██    ██ ██ ██  ██ ██   ██ ███████    "
echo "██      ██      ██    ██      ██ ██ ██  ██ ██ ██    ██     ██ ██  ██ ██          ██ ████  ██          ██ ██      ██      ██    ██ ██  ██ ██ ██   ██      ██    "
echo " ██████ ███████  ██████  ███████ ██ ██   ████  ██████      ██ ██   ████     ██████   ██████      ███████ ███████  ██████  ██████  ██   ████ ██████  ███████ ██ "
echo "                                                                                                                                                               "
echo "                                                                                                                                                               "
sleep 3
