create_rc_branch() {
  refresh_branch_state
  branch_name="release/goto${month}${full_day}${year}"
  printf "\n"
  printf "RC branch creation : ${month} ${year} \n"
  read -p "Are you sure you want to create the branch: '${branch_name}'?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    checkout_command=$(git checkout -b ${branch_name})
    push_command=$(git push --set-upstream origin ${branch_name})
  fi
}

refresh_branch_state() {
  clean_command=$(git clean -dfx)
  checkout_command=$(git checkout ${base_branch})
  pull_command=$(git pull origin ${base_branch})
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
create_rc_branch
#pull_request
