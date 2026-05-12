# tmux-notify zsh integration.
#
# Source from your ~/.zshrc, e.g.:
#   source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.zsh
#
# Then enable shell-hook mode in tmux:
#   set -g @tnotify-shell-integration 'on'

# Resolve this file's directory robustly whether sourced or executed.
_tmux_notify_self="${${(%):-%x}:A}"
_tmux_notify_script="${_tmux_notify_self:h}/../scripts/shell-hook.sh"

_tmux_notify_last_command=""

_tmux_notify_preexec() {
  # $1 is the command line as the user typed it.
  _tmux_notify_last_command="$1"
}

_tmux_notify_precmd() {
  local _exit=$?
  local _cmd="$_tmux_notify_last_command"
  _tmux_notify_last_command=""
  if [[ -n "$TMUX_PANE" && -x "$_tmux_notify_script" ]]; then
    "$_tmux_notify_script" "$_exit" "$_cmd" &!
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _tmux_notify_preexec
add-zsh-hook precmd _tmux_notify_precmd
