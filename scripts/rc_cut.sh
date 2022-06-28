# Color
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

print_separator() {
  printf "\n"
  printf "${YELLOW}▀▀▀▀▀${NC}\n"
}

print_check_mark() {
  " ${GREEN}\xE2\x9C\x94${NC}\n"
}

print_cross() {
  " ${RED}\xE2\x9D\x8C${NC}\n"
}

create_rc_branch() {
  refresh_branch_state
  branch_name="release/goto${month}${full_day}${year}"
  print_separator
  printf "RC branch creation : ${month} ${year} \n"
  printf "\n"
  read -p "Are you sure you want to create the branch: '${branch_name}'?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    checkout_command=$(git checkout -b ${branch_name})
    push_command=$(git push --set-upstream origin ${branch_name})
  fi
}

refresh_branch_state() {
  print_separator
  printf "Checkout base branch : ${base_branch} \n"
  printf "\n"

  if `git diff-index --quiet HEAD --`; then
    clean_command="deleting untracked files:"

    if `git clean -dfx > /dev/null` ; then
        printf "${clean_command} ${print_check_mark}" 
    else
        printf "${clean_command} ${print_cross}"
    fi
    
    checkout_command="checking out main branch:"
    
    if `git checkout ${base_branch} > /dev/null` ; then
        printf "${checkout_command} ${print_check_mark}"
    else
        printf "${checkout_command} ${print_cross}" 
    fi
    
    pull_command="pull code from origin:"
    
    if `git pull origin ${base_branch} > /dev/null` ; then
        printf "${pull_command} ${print_check_mark}"
    else
        printf "${pull_command} ${print_cross}"
    fi
  else
    printf "\n"
    printf "${RED}▀▀▀▀▀${NC}\n"
    printf "Your local repository has changes in it that prevent running this script\n"
    exit 0
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
day="$(date +'%d')"
full_day=$(format_day)
year="$(date +'%G')" 
welcome
create_rc_branch
#pull_request
