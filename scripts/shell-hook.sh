#!/usr/bin/env bash
## -- Shell-hook entry point
# Invoked from the user's zsh `precmd` or bash `PROMPT_COMMAND`.
# Fires a notification if monitoring was requested for this pane.
#
# Usage: shell-hook.sh [exit_status] [command]

# Bail quickly when not running inside tmux.
[[ -z "$TMUX_PANE" ]] && exit 0

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Derive the firing pane's ids from $TMUX_PANE (set by tmux in every pane)
# rather than from the *active* pane, which may have changed.
export PANE_ID="${TMUX_PANE#%}"
export SESSION_ID="$(tmux display-message -p -t "$TMUX_PANE" '#{session_id}' | tr -d $)"
export SESSION_NAME="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')"
export WINDOW_ID="$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' | tr -d @)"

source "${CURRENT_DIR}/helpers.sh"
source "${CURRENT_DIR}/variables.sh"

# Nothing to do if monitoring wasn't requested for this pane.
[[ ! -f "$HOOK_FILE_PATH" ]] && exit 0

exit_status="${1:-?}"
export TMUX_NOTIFY_COMMAND="${2-}"

# Sentinel format: "<refocus>|<telegram>"
IFS='|' read -r refocus telegram < "$HOOK_FILE_PATH"

# Remove sentinel up front so a slow notification path can't double-fire.
rm -f "$HOOK_FILE_PATH"

# Substitute the literal placeholder `#{tnotify_command}` with the captured
# command, escaping `#` so tmux's format engine doesn't re-interpret it.
expand_tnotify_command() {
  local fmt="$1"
  local cmd_escaped="${TMUX_NOTIFY_COMMAND//#/##}"
  printf '%s' "${fmt//'#{tnotify_command}'/$cmd_escaped}"
}

# Build message (mirrors notify.sh).
if verbose_enabled; then
  verbose_msg_value="$(get_tmux_option "$verbose_msg_option" "$verbose_msg_default")"
  verbose_msg_value="$(expand_tnotify_command "$verbose_msg_value")"
  complete_message=$(tmux display-message -p -t "$TMUX_PANE" "$verbose_msg_value")
  verbose_msg_title="$(get_tmux_option "$verbose_title_option" "$verbose_title_default")"
  verbose_msg_title="$(expand_tnotify_command "$verbose_msg_title")"
  complete_title=$(tmux display-message -p -t "$TMUX_PANE" "$verbose_msg_title")
elif [[ -n "$TMUX_NOTIFY_COMMAND" ]]; then
  complete_message="Tmux pane task completed: ${TMUX_NOTIFY_COMMAND} (exit ${exit_status})"
  complete_title=""
else
  complete_message="Tmux pane task completed! (exit ${exit_status})"
  complete_title=""
fi

if [[ "$refocus" == "true" ]]; then
  tmux switch -t \$"$SESSION_ID"
  tmux select-window -t @"$WINDOW_ID"
  tmux select-pane -t %"$PANE_ID"
fi

notify "$complete_message" "$complete_title" "$telegram"

run_user_cmd "$on_finish_command" "$on_finish_command_default" "$exit_status"

exit 0
