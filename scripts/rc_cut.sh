#!/usr/bin/env bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

welcome(){
  printf "                                               \n"
  printf "                                               \n"
  printf "                  ${GREEN}╓▄▄▓███▓▓▄▄                  \n"
  printf "              ╓▓████████████████▄              \n"
  printf "            ▄█████████████████████▀            \n"
  printf "          ╓███████▀╙       └╙▀██▀              \n"
  printf "         ▄██████¬                              \n"
  printf "        ]█████▌                                \n"
  printf "        ██████          ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓µ      \n"
  printf "        █████▌          ████████████████▌      \n"
  printf "        █████▌          ████████████████▌      \n"
  printf "        ╟█████                  ▓███████▌      \n"
  printf "         ██████▄               ▓████████▌      \n"
  printf "          ▀██████▄          ╓▓██████████▌      \n"
  printf "           ╙██████████▓▓██████████ █████▌      \n"
  printf "             └▀████████████████▀   █████▌      \n"
  printf "                 │╠╠▀▀▀▀▀▀▀╙│${YELLOW}░░░░░░${GREEN}▀▀▀▀▀▀${YELLOW}░░░${NC}   \n"
  printf "     ${YELLOW}░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   \n"
  printf "     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   \n"
  printf "     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░             \n"
  printf "     ░░░░░░░░${NC}                                  \n"
  printf "                                               \n"
  printf "                                               \n"
}

prerequisite() {
  print_separator
  printf "Tooling \n"
  printf "\n"
  install_brew
  install_jq
}

install_brew() {
  if ! command -v brew &> /dev/null
  then
    printf "brew could not be found"
    print_cross
    printf "Installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    printf "brew"
    print_check_mark
  fi
}

install_jq() {
  if ! command -v jq &> /dev/null
  then
    printf "jq could not be found"
    print_cross
    printf "Installing jq"
    brew install jq
  else
    printf "jq"
    print_check_mark
  fi
}

print_separator() {
  printf "\n"
  printf "${YELLOW}▀▀▀▀▀${NC}\n"
}

print_check_mark() {
  printf " ${GREEN}\xE2\x9C\x94${NC}\n"
}

print_cross() {
  printf " ${RED}\xE2\x9D\x8C${NC}\n"
}

create_rc_branch() {
  refresh_branch_state
  branch_name="release/goto${month}${full_day}${year}"
  print_separator
  printf "RC branch creation : %s %s \n" "$month" "$year"
  printf "\n"
  read -p "Are you sure you want to create the branch: '${branch_name}'?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    checkout_command="Checkout branch ${branch_name}:"

    if eval "git checkout -b ${branch_name} &> /dev/null" ; then
        printf "${checkout_command}"
        print_check_mark 
    else
        printf "${checkout_command}"
        print_cross
        exit 0
    fi

    push_command="Push branch ${branch_name}:"

    if eval "git push --set-upstream origin ${branch_name} &> /dev/null" ; then
        printf "${push_command}"
        print_check_mark 
    else
        printf "${push_command}"
        print_cross
        exit 0
    fi
  fi
}

refresh_branch_state() {
  print_separator
  printf "Checkout base branch : ${base_branch} \n"
  printf "\n"

  if eval "git diff-index --quiet HEAD --"; then
    clean_command="deleting untracked files:"

    if eval "git clean -dfx &> /dev/null" ; then
        printf "${clean_command}"
        print_check_mark 
    else
        printf "${clean_command}"
        print_cross
        exit 0
    fi
    
    checkout_command="checking out main branch:"
    
    if eval "git checkout ${base_branch} &> /dev/null" ; then
        printf "${checkout_command}"
        print_check_mark
    else
        printf "${checkout_command}" 
        print_cross
        exit 0
    fi
    
    pull_command="pull code from origin:"
    
    if eval "git pull origin ${base_branch} &> /dev/null" ; then
        printf "${pull_command}"
        print_check_mark
    else
        printf "${pull_command}"
        print_cross
        exit 0
    fi
  else
    printf "\n"
    printf "${RED}▀▀▀▀▀${NC}\n"
    printf "Your local repository has changes in it that prevent running this script\n"
    exit 0
  fi
  
}

bump_version() {
  refresh_branch_state
  print_separator
  printf "Updating app version \n"
  printf "\n"

  ## TODO add validation package.json exist
  previous_version=$(jq -r '.version' package.json)
  read -p "Are you sure you want to replace version \"${previous_version}\" by \"${next_version}\"?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    checkout_command="Checkout feature branch chore/app-version-${next_version_branch}:"
    
    if eval "git checkout -b chore/app-version-${next_version_branch} &> /dev/null" ; then
        printf "${checkout_command}"
        print_check_mark
    else
        printf "${checkout_command}"
        print_cross
        exit 0
    fi

    replace_command="Replace version(${previous_version}) => (${next_version}):"
    
    if eval "sed -i "" "s/${previous_version}/${next_version}/g" package.json &> /dev/null" ; then
        printf "${replace_command}"
        print_check_mark
    else
        printf "${replace_command}"
        print_cross
        exit 0
    fi

    commit_command="Commit change:"
    
    if eval "git commit -am "chore: updating version to ${next_version}" &> /dev/null" ; then
        printf "${commit_command}"
        print_check_mark
    else
        printf "${commit_command}"
        print_cross
        exit 0
    fi

    push_command="Push branch chore/app-version-${next_version_branch}"
    
    if eval "git push --set-upstream origin chore/app-version-${next_version_branch} &> /dev/null" ; then
        printf "${push_command}"
        print_check_mark
    else
        printf "${push_command}"
        print_cross
        exit 0
    fi
    
    pull_request
  fi
  
}

pull_request() {
  # try the upstream branch if possible, otherwise origin will do
  upstream=$(git config --get remote.upstream.url)
  origin=$(git config --get remote.origin.url)
  if [ -z $upstream ]; then
    upstream=$origin
  fi

  to_user=$(echo $upstream | sed -e 's/.*[\/:]\([^/]*\)\/[^/]*$/\1/')
  from_user=$(echo $origin | sed -e 's/.*[\/:]\([^/]*\)\/[^/]*$/\1/')
  repo=$(basename `git rev-parse --show-toplevel`)
  from_branch=$(git rev-parse --abbrev-ref HEAD)
  open "https://github.com/$to_user/$repo/pull/new/$to_user:$base_branch...$from_user:$from_branch"
}

format_day() {
  last_digit=${day: -1}
  full_day=""
  case "$last_digit" in
    1) 
      full_day="${day}st"
    ;;
    2) 
      full_day="${day}nd"
    ;;
    3) 
      full_day="${day}rd"
    ;;
    *) 
      full_day="${day}th"
    ;;
  esac

  echo "${full_day}"
}

base_branch="develop"
month="$(date +'%B')"
next_version="$(date -v+1m +'%G.%m')"
next_version_branch="$(date -v+1m +'%G-%m')"
day="$(date +'%d')"
full_day=$(format_day)
year="$(date +'%G')" 

welcome
prerequisite

create_rc_branch
bump_version
