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

_tmux_notify_precmd() {
  local _exit=$?
  if [[ -n "$TMUX_PANE" && -x "$_tmux_notify_script" ]]; then
    "$_tmux_notify_script" "$_exit" &!
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _tmux_notify_precmd
