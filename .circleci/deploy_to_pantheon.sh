#!/usr/bin/env bash

if [[ -z "$CIRCLECI" ]]; then
    echo "This script can only be run by CircleCI. Aborting." 1>&2
    exit 1
fi

if [[ -z "$CIRCLE_BRANCH" || "$CIRCLE_BRANCH" != "master" ]]; then
    echo "Build branch is required and must be 'master' branch. Stopping deployment." 1>&2
    exit 0
fi

if [[ -z "$TERMINUS_TOKEN" ]]; then
    echo "Terminus token not set. Aborting." 1>&2
    exit 1
fi

# Add global composer bin directory to $PATH variable
export PATH=$HOME/.composer/vendor/bin:$PATH

# Configure git
git config --global user.email "${GIT_EMAIL:-pantheon@circleci.com}"
git config --global user.name "${GIT_NAME:-Circle CI}"

# Configure SSH
echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config"

# Convert uploads directory to a symlink
sed -i '/web\/app\/uploads.*/d' .gitignore
rm -r web/app/uploads
ln -s ../../../files web/app/uploads

# Install Terminus globally
composer global require pantheon-systems/terminus:^1.9

# Install Terminus plugins
mkdir -p $HOME/.terminus/plugins
composer create-project -n -d $HOME/.terminus/plugins pantheon-systems/terminus-build-tools-plugin:^1.3

# Authenticate with Terminus
terminus auth:login -n --machine-token="$TERMINUS_TOKEN"

# Push code to Pantheon
terminus build:env:push -n "$TERMINUS_SITE.dev"
