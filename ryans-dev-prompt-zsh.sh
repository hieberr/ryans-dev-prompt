# **************************************************************
# Ryan Hieber's Custom Command Prompt
#
# Sample output:
# __________________________________________________________________.__________________________
# ~/repos/some_repo
# main [0|0]->origin/...
# $ git ci -m "Some commit message that easily fits in 50 spaces"

setopt promptsubst

NEWLINE=$'\n'

DEFAULT_COLOR="%F{240}" # light gray
RESET_COLOR="%f"

# The branch and the associated upstream remote/branch with the number of commits
# that branch is ahead and behind the upstream branch.
#
# If the the remote branch string contains the local branch string (usually they are
# the same for me) then the matching string is replaced with "..." to make it shorter.
# e.g.
#  remove-plus-flow [0|0]->origin/...
#
# [Ahead|Behind]
# Shows the number of commits that the branch is ahead or behind the upstream branch.
# If there are no untracked changes then the Ahead text is green. If there are untracked
# changes present then it is red.
#
# Rebasing status:
# If the repo is currently rebasing then "(Rebasing)" is inserted.
# e.g. # main [origin/main:0|2]
function git_info {
  inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

  if [ $inside_git_repo ]; then
    # The current branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    # The remote that the branch tracks
    remote=$(git config branch.$branch.remote)

    if [ "$remote" = "." ]; then
      # Branch is tracking another local branch.
      remote_path=""
      remote_branch=$(git config branch.$branch.merge | cut -d / -f 3-)
      remote_string="local"
    elif [ "$remote" != "" ]; then
      # Branch is tracking a remote branch.
      remote_path="$remote/"
      remote_branch=$(git config branch.$branch.merge | cut -d / -f 3-)
      remote_string="$remote"
    else
      # No tracking for this branch, so defualt to origin/main
      remote_string="(No upstream) origin"
      remote_path="origin/"
      remote_branch="main"
    fi

    # Ahead/Behind
    ahead_behind=$(git rev-list --left-right --count $branch...$remote_path$remote_branch | tr -s '\t' '|')
    ahead=$(cut -d "|" -f1 <<<$ahead_behind)
    behind=$(cut -d "|" -f2 <<<$ahead_behind)

    # Rebasing
    rebasing_string="(Rebasing)"
    test -d "$(git rev-parse --git-path rebase-merge)" || test -d "$(git rev-parse --git-path rebase-apply)" || rebasing_string=""

    # Tracked / untracked changes
    modified_files="$(git ls-files -m)"
    untracked_files="$(git status -s -uno)"
    all_changed_files=$(git status -s)
    if [ -n "$all_changed_files" ]; then
      # There are some changes
      if [ "$untracked_files" = "$all_changed_files" ] && [ -z "$modified_files" ]; then
        # Only added changes exist: Green
        ahead_color="%F{10}"
      else
        # Untracked or modified files exist: Red
        ahead_color="%F{9}"
      fi
    else
      # Working tree clean: Light Gray
      ahead_color=$DEFAULT_COLOR
    fi

    # If the remote branch text contains or equals the branch text then replace it with "..." to save space.
    remote_branch_string="${remote_branch/$branch/...}"

    # Need to assign bracket character to a variable otherwise it gets treated as an operater
    # in the expansion below.
    local bracket='['

    ahead_behind_part="$DEFAULT_COLOR$bracket$ahead_color$ahead$DEFAULT_COLOR|$behind]$RESET_COLOR"
    local_part="$DEFAULT_COLOR$branch$RESET_COLOR"
    upstream_part="$DEFAULT_COLOR->$remote_string/$remote_branch_string$RESET_COLOR"

    whole_string="$local_part $rebasing_string$ahead_behind_part$upstream_part"
    whole_string_length=$(echo -n $whole_string | wc -m)

    # Split the output into multiple lines if too large.
    if [ "$whole_string_length" -le "120" ]; then
      # The git info fits on one line.
      echo "$whole_string"
    else
      # The git info doesn't fit on a single line.
      echo "$local_part $rebasing_string$ahead_behind_part"
      echo "$upstream_part"
    fi
  fi
}

# A nice visual seperator.  Also a measuring tape for writing commit messages.
# The dot measures out the ideal commit summary length: 50 characters.
# The total length of the line measures out the max length for an 80
# character terminal which is 76 (git log pads 4 characters to the left).
# This assumes my typical git commit command of the form:
#     $ git ci -m "
# (Note that I have aliased the "commit" command to "ci"
function divider {
  DIVIDER_COLOR="%F{45}" # Teal
  # Space for the 'git ci -m "'  part of the message
  prefix="             "
  commit_space="                                                 .                        "
  echo "$DIVIDER_COLOR%U$prefix$commit_space%u$RESET_COLOR"
}

function prompt {
  PROMPT_COLOR="%F{45}" # Teal
  echo "$PROMPT_COLOR$ $RESET_COLOR"
}

function directory {
  echo "$DEFAULT_COLOR%1d $RESET_COLOR"
}

# Command to create the git information text. We can't just call git_info directly in PS1 since that
# seems to only run once when the script is initialized. We want it to be called every time
# the prompt updates. So, store the command itself rather than the output of the command.
git_info_command='$(git_info)'

# Assign the prompt format
PS1="$(divider)${NEWLINE}$(directory)$git_info_command${NEWLINE}$(prompt)"
