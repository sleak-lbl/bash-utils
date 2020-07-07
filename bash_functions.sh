# source this into bash environment to use theses functions

# dummy arg to add to env so bashrc etc dont repeatedly source this
# use like: [[ -z $_utils_defined ]] && source $HOME/bash_functions.sh
_utils_defined=1

pathadd () {
# add something to PATH, but only if it isn't already there 
# use like: 
# pathadd ${HOME}/bin ; pathadd ${HOME}/go/bin ; export PATH
# TODO handle -a / -p more gracefully (currently those break the check)
  if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
    if [[ "$1" == "-a" ]] ; then
      PATH="$PATH:$2"
    elif [[ "$1" == "-p" ]] ; then
      PATH="$2:$PATH"
    else
      PATH="$PATH:$1"
    fi
  fi
}

context() {
# save my bash history in different files according to what I'm doing, do make it
# easier to find stuff and continue working later
  local list=$(ls -lt ~/.histories/${2}* 2>/dev/null)
  if [[ -z $1 ]]; then
    [[ -z $CONTEXT ]] && { echo "(default context)"; (echo "$list" | head) } || echo "context: $CONTEXT"
  elif [[ $1 =~ ^-l ]]; then
    [[ "$1" == "-la" ]] && echo "$list" || (echo "$list" | head)
  else
    history -a
    { which conda >/dev/null 2>&1; } && conda deactivate 2>/dev/null
    local baseprompt=$(echo "$PS1" | sed 's/^\[[-A-Za-z0-9_]\+\] \(.*\)/\1/')
    if [[ $1 =~ ^- ]]; then
      #echo "clearing context"
      unset CONTEXT
      export HISTFILE=~/.bash_history
      PS1="$baseprompt"
    else
      if [[ ! -e ~/.histories/$1 ]]; then
        ls ~/.histories/
        read -e -p "create new? " -i $1
        [[ -z $REPLY ]] && return 1
      else
        REPLY=$1
      fi
      #echo "setting context to $1"
      export CONTEXT=$REPLY
      export HISTFILE=~/.histories/$CONTEXT
      PS1="[$CONTEXT] $baseprompt"
    fi
    history -r
  fi
}

lth () { 
  # usage: lth [pattern]
  # list the most recent n (=10 by default) files, optionally matching pattern
  # pattern must be something 'ls' understands
  local pattern=$*
  unset count
  unset d
  if [[ -n $* ]] ; then 
    if [[ $1 =~ ^-[0-9]+$ ]] ; then 
      count=$(($1-1)) ; shift ; pattern=$* 
    elif [[ ! $1 =~ ^- && ! -d $1 ]]; then 
      d='-d' 
    fi 
  fi
  ls -lt $d $pattern | head $count 
}

body () { 
  # pass the body - but not header line - of a text stram through some command. Eg:
  # head -20 sample.csv | body sort -n 
  local nh=1
  if [[ "$1" =~ -[0-9] ]]; then 
    nh=${1#-} ; shift
  fi
  cmd="$*"
  awk 'NR <= '$nh'; NR > '$nh' {print $0 | "'"$cmd"'"}' 
}

table () { 
  # pretty print tabular text stream that doesn't already play nicely with 'column'
  local sep=','
  if [[ $1 =~ ^-s ]]; then 
    sep=${1#-s}
    sep=${sep//[\'\"]/}
    if [[ -z $sep ]]; then 
      sep=${2//[\'\"]/}
    fi
  fi
  sed -e "s/$sep/ $sep/g" - | column -t -s$sep 
}

blockgrep () { 
  # apply grep to text that is arranged in blocks rather than lines (eg scontrol output)
  local p=$1; shift; 
  local awkcmd='BEGIN { RS="\n\n" ; ORS="\n\n" ; } '"/$p/ {print} ; {next} "
  awk "$awkcmd" $*
}

ssdiff ()
{
    # compact, side-by-side diff
    local pager="less -FX";
    if [[ "$1" == "-np" ]]; then
        pager=tee;
        shift;
    fi;
    sdiff -w $((COLUMNS-8)) $* | grep -n -T -C3 -e '[[:space:]][|<>][[:space:]]' -e '[[:space:]][|<>]$' | sed 's/./ /7' | $pager
}

function walk () {
    # read lines from a file, give user the chance to edit each
    # and then execute it:
    _verbose=0
    if [[ "$1" == "-v" ]] ; then
      _verbose=1
      shift
    fi

    while IFS='' read -r line || [[ -n "$line" ]]; do
        # skip blank lines
        [[ -z "$line" ]] && continue
        _m='^\s*#'
        if [[ "$line" =~ $_m ]] ; then
            echo -e "$line"
            continue
        fi
        # do variable expansion so it is explicit what will be run
        # (to avoid "forgot to set the variable, overwrote the wrong thing"
        # type errors):
        expline=$(envsubst <<< "$line")
        # 'read' seems to clear escape characters, so replace each with
        # two (to escape the escape char):
        escapes=$(sed -e 's/\\/\\\\/g' <<< "$expline")

        fail=1
        while (( $fail )) ; do
            # give the user a chance to edit (or delete) the command:
            read -i "$escapes" -e cmd < /dev/tty
            # print what will actually get run:
            (( $_verbose )) && echo -e "$cmd"
            # run what remains:
            eval $cmd
            fail=$?
            (( $fail )) && echo "failed - try again?"
        done
    done < "$1"
}





