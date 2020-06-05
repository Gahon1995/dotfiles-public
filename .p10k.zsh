unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir)
[[ -e ~/.ssh/id_rsa ]] && POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(my_git_dir vcs)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(newline prompt_char)

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs context)
(( $+commands[nordvpn] )) && POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(nordvpn)
(( P9K_SSH             )) && POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(time)

POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_ICON_PADDING=none
POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
POWERLEVEL9K_ICON_BEFORE_CONTENT=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

POWERLEVEL9K_DIR_FOREGROUND=31
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
POWERLEVEL9K_SHORTEN_DELIMITER=
POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
POWERLEVEL9K_DIR_ANCHOR_BOLD=true
POWERLEVEL9K_SHORTEN_FOLDER_MARKER=.git
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_DIR_MAX_LENGTH=80
POWERLEVEL9K_DIR_SHOW_WRITABLE=v2
POWERLEVEL9K_DIR_CLASSES=()

function prompt_my_git_dir() {
  emulate -L zsh
  [[ -n $GIT_DIR ]] || return
  local repo=${GIT_DIR:t}
  [[ $repo == .git ]] && repo=${GIT_DIR:h:t}
  [[ $repo == .dotfiles-(public|private) ]] && repo=${repo#.dotfiles-}
  p10k segment -b 0 -f 208 -t ${repo//\%/%%}
}

function my_git_formatter() {
  emulate -L zsh

  if [[ -n $P9K_CONTENT ]]; then
    typeset -g my_git_format=$P9K_CONTENT
    return
  fi

  if (( $1 )); then
    local       meta='%f'
    local      clean='%76F'
    local   modified='%178F'
    local  untracked='%39F'
    local conflicted='%196F'
  else
    local       meta='%244F'
    local      clean='%244F'
    local   modified='%244F'
    local  untracked='%244F'
    local conflicted='%244F'
  fi

  local res where
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    res+="${clean}"
    where=${(V)VCS_STATUS_LOCAL_BRANCH}
  elif [[ -n $VCS_STATUS_TAG ]]; then
    res+="${meta}#"
    where=${(V)VCS_STATUS_TAG}
  fi

  (( $#where > 32 )) && where[13,-13]="…"
  res+="${clean}${where//\%/%%}"
  [[ -z $where ]] && res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
    res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  fi

  (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
  (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"
  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

  typeset -g my_git_format=$res
}
functions -M my_git_formatter 2>/dev/null

POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178

POWERLEVEL9K_STATUS_EXTENDED_STATES=true
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_OK_FOREGROUND=70
POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
POWERLEVEL9K_STATUS_OK_PIPE=true
POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
POWERLEVEL9K_STATUS_ERROR=false
POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
POWERLEVEL9K_STATUS_ERROR_PIPE=true
POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160
POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=101
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70

POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=178
POWERLEVEL9K_CONTEXT_FOREGROUND=180
POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=81
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE=${${Z4H_SSH//\%/%%}:-%m}

POWERLEVEL9K_NORDVPN_FOREGROUND=39
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_TIME_FOREGROUND=66
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=

POWERLEVEL9K_TRANSIENT_PROMPT=always
POWERLEVEL9K_INSTANT_PROMPT=quiet
POWERLEVEL9K_DISABLE_HOT_RELOAD=true
POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ! $+functions[p10k] )) || p10k reload