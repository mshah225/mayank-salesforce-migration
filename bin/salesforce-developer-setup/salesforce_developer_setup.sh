#!/bin/bash

# Ensure that ASU is set as a remote
git remote add ASU https://github.com/ASU/crm-salesforce-enterprise

# Keep Homebrew up-to-date
if [ "$(uname)" == "Darwin" ]; then
    brew update
    brew upgrade
fi

# Keep npm up-to-date
npm list --location=global | grep sfdx-cli || npm install --location=global sfdx-cli
npm list --location=global | grep prettier || npm install --location=global -D -E prettier
npm list --location=global | grep prettier-plugin-apex || npm install --location=global -D -E prettier-plugin-apex
npm list | grep prettier || npm install --save-dev --save-exact prettier
npm list | grep prettier-plugin-apex || npm install --save-dev --save-exact prettier-plugin-apex
npm list | grep eslint || npm install --save-dev eslint
npm list | grep @babel/core || npm install --save-dev @babel/core
npm list | grep @babel/eslint-parser || npm install --save-dev @babel/eslint-parser
npm list | grep @lwc/eslint-plugin-lwc || npm install --save-dev @lwc/eslint-plugin-lwc
npm list | grep @salesforce/eslint-plugin-aura || npm install --save-dev @salesforce/eslint-plugin-aura
npm list | grep husky && [ $? -eq 0 ] && npm uninstall husky && npm install -D husky@4 || npm install -D husky@4
npm update
npm update --location=global

# Force Visual Studio Code to install or update the extensions
code --install-extension salesforce.salesforcedx-vscode --force
code --install-extension dbaeumer.vscode-eslint --force
code --install-extension esbenp.prettier-vscode --force
code --install-extension fabiospampinato.vscode-commands --force
code --install-extension fabiospampinato.vscode-terminals --force
code --install-extension ms-python.python --force
code --install-extension ms-python.black-formatter --force
code --install-extension foxundermoon.shell-format --force

reset && exit
