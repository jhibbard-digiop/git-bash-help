#!/bin/bash

alias gbl='git branch -l'
alias gcb='git checkout -b'
alias gcm='git add . && git commit -m'
alias gs='git status'
alias gdb='git branch -D'
alias gdiff='git diff'
alias glog='git log'
alias grlog='git reflog'
alias gco='git checkout'

function gcor {
  if [ $# -eq 0 ];then
    echo "Please input branch name"
    return 1
  fi

  BRANCH_NAME=$1
  MAIN_BRANCH_NAME="main"

  if [ `git branch | grep $MAIN_BRANCH_NAME` ];then
      MAIN_BRANCH_NAME="main"
  else
      MAIN_BRANCH_NAME="master"
  fi
  git checkout $MAIN_BRANCH_NAME
  git pull origin $MAIN_BRANCH_NAME
  git fetch
  git checkout $BRANCH_NAME
}

function gpo {
	SOURCE_BRANCH=""
	CURRENT_BRANCH_NAME=$(git branch --show-current)

	if [ $# -eq 0 ];then
		SOURCE_BRANCH=$CURRENT_BRANCH_NAME
	else
		SOURCE_BRANCH=$1
	fi

	git push origin $SOURCE_BRANCH
}

function isLocalBranch() {
    local branch=${1}
    local existed_in_local=$(git branch --list ${branch})

    if [[ -z ${existed_in_local} ]]; then
        echo 0
    else
        echo 1
    fi
}

# Remote:
# Ref: https://stackoverflow.com/questions/8223906/how-to-check-if-remote-branch-exists-on-a-given-remote-repository
# test if the branch is in the remote repository.
# return 1 if its remote branch exists, or 0 if not.
function isRemoteBranch() {
    local branch=${1}
    local existed_in_remote=$(git ls-remote --heads origin ${branch})

    if [[ -z ${existed_in_remote} ]]; then
        echo 0
    else
        echo 1
    fi
}

function grnb {
  NEW_BRANCH_NAME=$1
  CURRENT_BRANCH_NAME=$(git branch --show-current)

  git branch -m $CURRENT_BRANCH_NAME $NEW_BRANCH_NAME
  git push origin :$CURRENT_BRANCH_NAME $NEW_BRANCH_NAME
  git push origin -u $NEW_BRANCH_NAME
}

function gup {
  MERGE_SOURCE_BRANCH=""
  CURRENT_BRANCH_NAME=$(git branch --show-current)
  MAIN_BRANCH_NAME="develop"

  git checkout $CURRENT_BRANCH_NAME

  if [ $# -eq 0 ];then
    git pull origin $CURRENT_BRANCH_NAME
    return 1
  fi

  if [ `git branch | grep develop` ];then
      MAIN_BRANCH_NAME="develop"
  elif [ `git branch | grep main` ];then
      MAIN_BRANCH_NAME="main"
  else
      MAIN_BRANCH_NAME="master"
  fi

  git checkout $MAIN_BRANCH_NAME 1> /dev/null
  git pull origin $MAIN_BRANCH_NAME 1> /dev/null
  git fetch origin 1> /dev/null
  git fetch 1> /dev/null

  if [ isLocalBranch $1 ]; then
      git checkout $1
      git pull origin $1
  elif [ isRemoteBranch $1]; then
      gcor $1
  else
      echo "Invalid Target Branch to merge with!"
      return 1
  fi

  git checkout $1
  git pull origin $1
  git checkout $CURRENT_BRANCH_NAME
  git merge $1
}
