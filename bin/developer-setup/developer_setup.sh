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

# Developer setup tasks to complete
git remote add ASU https://github.com/ASU/crm-salesforce-enterprise &>/dev/null
npm install --save-dev --save-exact prettier prettier-plugin-apex &>/dev/null
npm config set prefix /usr/local &>/dev/null
npm install -g -D -E prettier prettier-plugin-apex &>/dev/null
code --install-extension salesforce.salesforcedx-vscode &>/dev/null
code --install-extension dbaeumer.vscode-eslint &>/dev/null
code --install-extension esbenp.prettier-vscode &>/dev/null
code --install-extension fabiospampinato.vscode-commands &>/dev/null
code --install-extension fabiospampinato.vscode-terminals &>/dev/null
code --install-extension ms-python.python &>/dev/null

echo " ██████ ██       ██████  ███████ ██ ███    ██  ██████      ██ ███    ██     ██████   ██████      ███████ ███████  ██████  ██████  ███    ██ ██████  ███████    "
echo "██      ██      ██    ██ ██      ██ ████   ██ ██           ██ ████   ██          ██ ██  ████     ██      ██      ██      ██    ██ ████   ██ ██   ██ ██         "
echo "██      ██      ██    ██ ███████ ██ ██ ██  ██ ██   ███     ██ ██ ██  ██      █████  ██ ██ ██     ███████ █████   ██      ██    ██ ██ ██  ██ ██   ██ ███████    "
echo "██      ██      ██    ██      ██ ██ ██  ██ ██ ██    ██     ██ ██  ██ ██          ██ ████  ██          ██ ██      ██      ██    ██ ██  ██ ██ ██   ██      ██    "
echo " ██████ ███████  ██████  ███████ ██ ██   ████  ██████      ██ ██   ████     ██████   ██████      ███████ ███████  ██████  ██████  ██   ████ ██████  ███████ ██ "
echo "                                                                                                                                                               "
echo "                                                                                                                                                               "
