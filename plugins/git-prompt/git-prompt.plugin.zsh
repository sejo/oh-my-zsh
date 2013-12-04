# ZSH Git Prompt Plugin from:
# http://github.com/olivierverdier/zsh-git-prompt
#
export __GIT_PROMPT_DIR=$ZSH/plugins/git-prompt
# Initialize colors.
autoload -U colors
colors

# Allow for functions in the prompt.
setopt PROMPT_SUBST

## Enable auto-execution of functions.
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# Append git functions needed for prompt.
preexec_functions+='preexec_update_git_vars'
precmd_functions+='precmd_update_git_vars'
chpwd_functions+='chpwd_update_git_vars'

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
    _GIT_STATUS=`python ${gitstatus}`
    __CURRENT_GIT_STATUS=("${(f)_GIT_STATUS}")
	GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
        GIT_REMOTE=$__CURRENT_GIT_STATUS[2]
        GIT_STAGED=$__CURRENT_GIT_STATUS[3]
        GIT_CONFLICTS=$__CURRENT_GIT_STATUS[4]
        GIT_CHANGED=$__CURRENT_GIT_STATUS[5]
        GIT_UNTRACKED=$__CURRENT_GIT_STATUS[6]
        GIT_CLEAN=$__CURRENT_GIT_STATUS[7]
}

git_super_status() {
        precmd_update_git_vars
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
          STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"
          if [ -n "$GIT_REMOTE" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE$GIT_REMOTE%{${reset_color}%}"
          fi
          STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
          if [ "$GIT_STAGED" -ne "0" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
          fi
          if [ "$GIT_CONFLICTS" -ne "0" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
          fi
          if [ "$GIT_CHANGED" -ne "0" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED%{${reset_color}%}"
          fi
          if [ "$GIT_UNTRACKED" -ne "0" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED%{${reset_color}%}"
          fi
          if [ "$GIT_CLEAN" -eq "1" ]; then
                  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
          fi
          STATUS="$STATUS%{${reset_color}%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
          echo "$STATUS"
        fi
}

function prompt_git_info() {
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
        echo "(%{${fg[red]}%}$__CURRENT_GIT_STATUS[1]%{${fg[default]}%}$__CURRENT_GIT_STATUS[2]%{${fg[magenta]}%}$__CURRENT_GIT_STATUS[3]%{${fg[default]}%})"
    fi
}

# Set the prompt.
#PROMPT='%B%m%~%b$(prompt_git_info) %# '
PROMPT='%B%m%~%b$(git_super_status) %# '
# for a right prompt:
#RPROMPT='%b$(prompt_git_info)'
RPROMPT='$(prompt_git_info)'
