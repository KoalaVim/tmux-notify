# tmux-notify fish integration. Requires fish >= 3.2.
#
# Source from your fish config, e.g.:
#   source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.fish
#
# Then enable shell-hook mode in tmux:
#   set -g @tnotify-shell-integration 'on'

set -g _tmux_notify_script (dirname (status current-filename))/../scripts/shell-hook.sh

function _tmux_notify_postexec --on-event fish_postexec
    set -l _exit $status
    # $argv[1] is the command line that just finished.
    set -l _cmd $argv[1]
    if test -n "$TMUX_PANE" -a -x "$_tmux_notify_script"
        $_tmux_notify_script $_exit "$_cmd" &
        disown
    end
end
