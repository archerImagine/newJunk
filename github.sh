#!/bin/bash
#
# Copyright 2011, Tim Branyen @tbranyen <tim@tabdeveloper.com>
# Dual licensed under the MIT and GPL licenses.
#
# Automatically clone single or multiple repos into a folder,
# great for setting up a git projects folder.
#
# Install: curl https://gist.github.com/raw/902154/github.sh > /usr/local/bin/gh
#          chmod +x /usr/local/bin/gh
#

# Internal properties
GITHUB_PREFIX=https://github.com/
GITHUB_USERNAME=$(git config --global github.user)

function main {
  # Improperly configured user
  detect_user

  # Missing arguments
  args=$@
  arg1=$1
  if [ -z $arg1 ]; then
    echo '
      gh: try ''`gh --help`'' for more information
    '
    exit
  fi

  # Display help text
  if [ $arg1 = '--help' ]; then
    echo '
      Clone repos from your GitHub
        gh repo1 repo2

      Clone repos from others GitHub
        gh username/repo1 username/repo2

      Clone mixed repos:
        gh repo1 username/repo2

      Clone line separated repos from file:
        cat file | xargs gh
    '
    exit
  fi

  # Parse arguments and clone repos.
  find_repos
}

function detect_user {
  # If no username configured, attempt to pull from git --config
  if [ -n "$GITHUB_USERNAME" ]; then
    USERNAME=$GITHUB_USERNAME
  else
    echo '
      gh: missing username
      configure username with ''`git config --global github.user username`''
    '
    exit
  fi
}

function find_repos {
  for repo in $args; do
    echo 'in find_repos for'
    echo ''
    # If a user provides the parameter username/repo pull in that specific repository.
    if [ `awk -v repo="$repo" -v delimit="/" 'BEGIN{print index(repo,delimit)}'` -ne 0 ]; then
      echo "Pulling in $repo";
      git clone --depth=1 $GITHUB_PREFIX$repo.git || true

    # Default to you.
    else
      echo "Pulling in $USERNAME/$repo";
      git clone --depth=1 $GITHUB_PREFIX$USERNAME/$repo.git
    fi
  done
}

main $@