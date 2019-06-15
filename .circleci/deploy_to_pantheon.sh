#!/usr/bin/env bash

if [[ -z "$CIRCLECI" ]]; then
    echo "This script can only be run by CircleCI. Aborting." 1>&2
    exit 1
fi

if [[ -z "$TERMINUS_SITE" ]]; then
    echo "Terminus site not set. Aborting." 1>&2
    exit 1
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
mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/config"
echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config"

# Convert uploads directory to a symlink
sed -i '/web\/app\/uploads.*/d' .gitignore
rm -r web/app/uploads
ln -s ../../../files web/app/uploads

# Install Terminus globally
composer global require pantheon-systems/terminus:^2.0

# Install Terminus plugins
mkdir -p $HOME/.terminus/plugins
composer create-project -n -d $HOME/.terminus/plugins pantheon-systems/terminus-build-tools-plugin:^2.0.0-beta13

# Authenticate with Terminus
terminus auth:login -n --machine-token="$TERMINUS_TOKEN"

# Wake up the main development environment
terminus env:wake -n "$TERMINUS_SITE.dev"

# Push code to Pantheon
if [[ ${CIRCLE_BRANCH} == "master" ]]; then
    terminus build:env:push -n "$TERMINUS_SITE.dev"
elif [[ ! -z "$CIRCLE_PULL_REQUEST" ]]; then
    terminus build:env:create -n "$TERMINUS_SITE.dev" "pr-${CIRCLE_PULL_REQUEST##*/}"
fi

# Clean up unused PR environments (if GITHUB_TOKEN is set)
if [[ ! -z "$GITHUB_TOKEN" ]]; then
    terminus build:env:delete:pr -n "$TERMINUS_SITE" --yes
fi
