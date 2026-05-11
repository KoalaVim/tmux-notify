#!/usr/bin/env bash
## -- Add tmux plugin variables

## Main variables
if [[ -z $XDG_CACHE_HOME ]]; then
  export PID_DIR=~/.tmux/notify
else
  export PID_DIR="$XDG_CACHE_HOME/tmux/tmux-notify"
fi

# Get ID's (respect pre-set values so shell-hook.sh can target the firing pane)
export SESSION_ID="${SESSION_ID:-$(tmux display-message -p '#{session_id}' | tr -d $)}"
export SESSION_NAME="${SESSION_NAME:-$(tmux display-message -p '#{session_name}')}"
export WINDOW_ID="${WINDOW_ID:-$(tmux display-message -p '#{window_id}' | tr -d @)}"
export PANE_ID="${PANE_ID:-$(tmux display-message -p '#{pane_id}' | tr -d %)}"
export PID_FILE_PATH="${PID_DIR}/${PANE_ID}.pid"
export HOOK_FILE_PATH="${PID_DIR}/${PANE_ID}.hook"

## Tnotify tmux options
export prompt_suffixes="@tnotify-prompt-suffixes"
export prompt_suffixes_default="$,#,%"
export on_finish_command="@tnotify-on-finish"
export on_finish_command_default=""
export on_start_command="@tnotify-on-start"
export on_start_command_default=""

# Notification verbosity settings
export verbose_option="@tnotify-verbose"
export verbose_default="off"
export verbose_msg_option="@tnotify-verbose-msg"
export verbose_msg_default="(#S, #I:#P) Tmux pane task completed!"
export verbose_title_option="@tnotify-verbose-title"
export verbose_title_default=""

# Monitor checker interval
export monitor_sleep_duration="@tnotify-sleep-duration"
export monitor_sleep_duration_default=10

# Shell-hook integration (precmd / PROMPT_COMMAND)
export shell_integration_option="@tnotify-shell-integration"
export shell_integration_default="off"

# Telegram notification settings
export tmux_notify_telegram_bot_id="@tnotify-telegram-bot-id"
export tmux_notify_telegram_channel_id="@tnotify-telegram-channel-id"
export tmux_notify_telegram_all="@tnotify-telegram-all"
export tmux_notify_telegram_bot_id_default=""
export tmux_notify_telegram_channel_id_default=""
export tmux_notify_telegram_all_default="off"

# Pushover notification settings
export tmux_notify_pushover_token="@tnotify-pushover-token"
export tmux_notify_pushover_user="@tnotify-pushover-user"
export tmux_notify_pushover_title="@tnotify-pushover-title"
export tmux_notify_pushover_token_default=""
export tmux_notify_pushover_user_default=""
export tmux_notify_pushover_title_default="Tmux Notify"
