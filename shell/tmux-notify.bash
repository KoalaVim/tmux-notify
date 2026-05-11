# tmux-notify bash integration.
#
# Source from your ~/.bashrc, e.g.:
#   source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.bash
#
# Then enable shell-hook mode in tmux:
#   set -g @tnotify-shell-integration 'on'

_tmux_notify_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../scripts/shell-hook.sh"

_tmux_notify_prompt_command() {
  local _exit=$?
  if [[ -n "$TMUX_PANE" && -x "$_tmux_notify_script" ]]; then
    "$_tmux_notify_script" "$_exit" &
    disown 2>/dev/null
  fi
  return $_exit
}

# Prepend so $? is captured before anything else in PROMPT_COMMAND clobbers it.
case ";${PROMPT_COMMAND};" in
  *";_tmux_notify_prompt_command;"*) ;;
  *) PROMPT_COMMAND="_tmux_notify_prompt_command;${PROMPT_COMMAND}" ;;
esac
