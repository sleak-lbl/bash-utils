#!/bin/bash

function git_info ()
{
  local br dt start end num
  num='-0'  # max branches to show
  search="" # filter branches by this
  full=0    # (don't) show which files were changed
  while [[ -n "$1" ]] ; do
    case $1 in
       -n*) num=${1#-n} ; [[ -z $num ]] && { num=$2 ; shift ; } ;;
       -f) full=1 ;;
       *) search=$1 ;;
    esac
    shift
  done

  # show known remotes
  git remote -v show

  # show known branches (optionally limited to current + first $num matching search)
  local cb=$(git rev-parse --abbrev-ref HEAD)
  # colorize the current branch:
  local cstart='* \e[32m'
  local cend='\e[0m'
  local count=0
  git for-each-ref --sort=-committerdate refs/ --format='%(committerdate) %(authorname) %09 |%(refname:short)' | while IFS='|' read dt br ; do
    if [[ $br == $cb ]]; then
      printf "$cstart%-30s %s$cend\\n" "$dt" "$br"
    elif [[ $num -le 0 || $count -le $num ]]; then
      if [[ "$dt $br" =~ $search ]]; then
        printf "%-30s %s\\n" "$dt" "$br"
        let count+=1
      fi
    fi
  done

  # show last commit
  git --no-pager log -n 1 --name-status | head ; echo '...'

  # show local status:
  if (( $full )); then
    local=$(git stat -s | paste - -)
  else
    local=$(git stat -s | cut -c-2 | uniq -c | paste - -)
  fi
  [[ -n "$local" ]] && echo "local changes:" && echo "$local"
}

git_info $*
