# tmux-notify <!-- omit in toc -->

[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green)](https://github.com/rickstaa/tmux-notify/pulse)
[![Contributions](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Tmux version](https://img.shields.io/badge/tmux-%3D%3E1.9-blue)](https://github.com/tmux/tmux/wiki)

<a href="https://github.com/rickstaa/tmux-notify"><img src="resources/tmux-notify-logo.svg" alt="tmux notify logo" width="567" height="135"/></a>

Tmux plugin to notify you when processes are finished.

> \[!NOTE]\
> Notifications are sent via [libnotify](https://gitlab.gnome.org/GNOME/libnotify), and visual bells are raised in the Tmux window. Visual bells can be mapped (in the terminal level) to the X11 urgency bit and handled by your window manager.

## Table of Contents <!-- omit in toc -->

*   [Use cases](#use-cases)
*   [Pre-requisites](#pre-requisites)
*   [Install](#install)
*   [Usage](#usage)
*   [Configuration](#configuration)
    *   [Enable verbose notification](#enable-verbose-notification)
    *   [Change monitor update period](#change-monitor-update-period)
    *   [Add additional shell suffixes](#add-additional-shell-suffixes)
    *   [Enable telegram channel notifications](#enable-telegram-channel-notifications)
    *   [Enable Pushover notifications](#enable-pushover-notifications)
    *   [Execute custom user commands](#execute-custom-user-commands)
    *   [Shell-hook detection (zsh / bash / fish)](#shell-hook-detection-zsh--bash--fish)
*   [How does it work](#how-does-it-work)
*   [Other use cases](#other-use-cases)
    *   [Use inside a docker container](#use-inside-a-docker-container)
*   [Contributing](#contributing)
*   [References](#references)

## Use cases

*   When you have already started a process in a pane and wish to be notified (i.e. you can't use a manual trigger).
*   Working in different containers (Docker) -> can't choose the shell -> and can't use a shell-level feature.
*   Working over ssh, but your Tmux is on the client side.

## Pre-requisites

*   Bash
*   Tmux
*   `notify-send` or `osascript`.
*   **Optional**: `wget` (for telegram notifications).

> \[!NOTE]\
> Works on Linux and macOS (note: only actively tested on Linux).

## Install

Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm), add:

    set -g @plugin 'rickstaa/tmux-notify'

to your `.tmux.conf`.

Use `prefix + I` to install.

## Usage

*   `prefix + m`: Start monitoring a pane and notify when it finishes.

*   `prefix + alt + m`: Start monitoring a pane, return it in focus and notify when it finishes.

*   `prefix + M`: Cancel monitoring of a pane.

> \[!IMPORTANT]\
> There is a known issue with alt-based Tmux shortcuts on osx. If you encounter problems, please check [this post](https://superuser.com/questions/649960/option-key-does-not-work-as-meta-in-tmux) for a workaround.

## Configuration

### Enable verbose notification

The default notification text is `Tmux pane task completed!`. This tool also contains a verbose output option which gives more information about the pane, window, and session the task has completed.

> To enable this, put `set -g @tnotify-verbose 'on'` in the `.tmux.conf` config file.

#### Change the verbose notification message

To change the verbose notification text, put `set -g @tnotify-verbose-msg 'put your notification text here'` in the `.tmux.conf` config file. You can use all the Tmux variables in your notification text. Some useful Tmux aliases are:

*   `#D`: Pane id
*   `#P`: Pane index
*   `#T`: Pane title
*   `#S`: Session name
*   `#I`: Window index
*   `#W`: Window name

For the complete list of aliases and variables, you are referred to the `FORMATS` section of the [tmux manual](http://man7.org/linux/man-pages/man1/tmux.1.html). You can also add a notification title using `set -g @tnotify-verbose-title`. Doing so will move the verbose notification text into the notification body.

Literal `\n` sequences in the verbose message or title are converted to real newlines, so you can produce multi-line notifications, e.g. `set -g @tnotify-verbose-msg '(#S) done\nexit: ?'`.

When [shell-hook detection](#shell-hook-detection-zsh--bash--fish) is enabled on zsh or fish, you can also include the command that just finished by putting `#{tnotify_command}` in your verbose message or title — for example:

```tmux
set -g @tnotify-verbose-msg '(#S, #I:#P) finished: #{tnotify_command}'
```

In polling mode and under bash, `#{tnotify_command}` expands to an empty string.

### Change monitor update period

By default, the monitor sleep period is set to 10 seconds. This means that tmux-notify checks the pane activity every 10 seconds.

> Put `set -g @tnotify-sleep-duration 'desired duration'` in the `.tmux.conf` file to change this duration.

> \[!WARNING]\
> Remember that there is a trade-off between notification speed (short sleep duration) and the amount of memory this tool needs.

### Add additional shell suffixes

The Tmux notify script uses your shell prompt suffix to check whether a command has finished. By default, it looks for the `$`, `#` and `%` suffixes.

> Put `set -g @tnotify-prompt-suffixes 'put your comma-separated bash suffix list here'` in the `.tmux.conf` file to add additional suffixes.

> \[!NOTE]\
> Feel free to open [a pull](https://github.com/rickstaa/tmux-notify/pulls) request or [issue](https://github.com/rickstaa/tmux-notify/issues) if you think your shell prompt suffix should be included by default.

### Enable telegram channel notifications

> \[!WARNING]\
> This feature requires [wget](https://www.gnu.org/software/wget/) to be installed on your system.

By default, the tool only sends operating system notifications. It can, however, also send a message to a user-specified telegram channel.

> Put `set -g @tnotify-telegram-bot-id 'your telegram bot id'` and `set -g @tnotify-telegram-channel-id 'your channel id'` in the `.tmux.conf` config file to enable this.

After enabling this option, the following key bindings are available:

*   `prefix + ctrl + m`: Start monitoring pane and notify in bash and telegram when it finishes.

*   `prefix + ctrl + alt + m`: Start monitoring a pane, return it in focus and notify in bash and telegram when it finishes.

Additionally, you can use the `set -g @tnotify-telegram-all 'on'` option to send all notifications to telegram.

> \[!NOTE]\
> You can get your telegram bot id by creating a bot using [BotFather](https://core.telegram.org/bots#6-botfather) and your channel id by sending your channel invite link to the `@username_to_id_bot` bot.

### Enable Pushover notifications

> \[!WARNING]\
> This feature requires [curl](https://curl.se/) to be installed on your system.

By default, the tool only sends operating system notifications. It can, however, also send a message to a user-specified pusher user or group.

> Put `set -g @tnotify-pushover-token 'your pushover application token'` and `set -g @tnotify-pushover-user 'your pushover user or group identifier'` in the `.tmux.conf` config file to enable this.

> You may optionally put `set -g @tnotify-pushover-title 'The title of the message'` to override the default title

> \[!NOTE]\
> You can create a free pushover account at [pushover.net](https://pushover.net/).

### Execute custom user commands

Two hooks are available for running your own commands around the monitoring lifecycle. Both are set as tmux options and executed via `eval`.

| Option                | When it fires                                        |
| --------------------- | ---------------------------------------------------- |
| `@tnotify-on-start`   | Right after you trigger monitoring.                  |
| `@tnotify-on-finish`  | After the completion notification fires.             |
| `@tnotify-on-cancel`  | After monitoring is canceled via the cancel keybind. |

Example:

```tmux
set -g @tnotify-on-start  'echo "monitoring $TMUX_NOTIFY_PANE_ID" >> ~/.tmux/notify.log'
set -g @tnotify-on-finish 'bash ~/bin/on-tnotify-finish.sh'
set -g @tnotify-on-cancel 'echo "canceled $TMUX_NOTIFY_PANE_ID" >> ~/.tmux/notify.log'
```

Each command runs with these environment variables exported:

*   `TMUX_NOTIFY_PANE_ID` — the monitored pane's id (without the `%`)
*   `TMUX_NOTIFY_SESSION_ID` — session id (without the `$`)
*   `TMUX_NOTIFY_SESSION_NAME` — session name
*   `TMUX_NOTIFY_WINDOW_ID` — window id (without the `@`)
*   `TMUX_NOTIFY_EXIT_STATUS` — exit status of the finished command (only set for `@tnotify-on-finish`, and only meaningful when [shell-hook detection](#shell-hook-detection-zsh--bash--fish) is enabled; empty in polling mode)
*   `TMUX_NOTIFY_COMMAND` — the command line that just finished (only set for `@tnotify-on-finish`, and only when [shell-hook detection](#shell-hook-detection-zsh--bash--fish) is enabled with zsh or fish; empty in bash and in polling mode)

> \[!WARNING]\
> Both commands are executed with `eval`, so [be careful with what you put in here](https://stackoverflow.com/a/17529221/8135687).

> \[!NOTE]\
> Please consider contributing to [this repository](https://github.com/rickstaa/tmux-notify) if your custom command is useful for others.

### Shell-hook detection (zsh / bash / fish)

By default the plugin polls the pane's output every few seconds and guesses that a command has finished when the last line looks like a shell prompt (see [Add additional shell suffixes](#add-additional-shell-suffixes)). This works inside any pane, including non-shells, but it can mis-fire or fire late.

If you only care about *real* shells, you can switch to an event-driven mode that hooks into your shell's pre-prompt callback (`precmd` for zsh, `PROMPT_COMMAND` for bash, `fish_postexec` for fish). Notifications fire the instant the command returns and include the exit status. On zsh and fish, the command line that just ran is included in the default notification text too.

**1. Enable in your tmux config:**

```tmux
set -g @tnotify-shell-integration 'on'
```

**2. Source the matching snippet from your shell's rc file:**

```zsh
# ~/.zshrc
source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.zsh
```

```bash
# ~/.bashrc
source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.bash
```

```fish
# ~/.config/fish/config.fish (requires fish >= 3.2)
source ~/.tmux/plugins/tmux-notify/shell/tmux-notify.fish
```

Reload tmux (`prefix + I` or `tmux source-file ~/.tmux.conf`), open a new shell, then use `prefix + m` as usual.

> \[!NOTE]\
> Shell-hook mode only fires for commands run from your interactive shell. Long-running non-shell programs (REPLs, `top`, an `ssh` session without this integration on the remote side, etc.) won't trigger a notification. If you need to cover those cases, leave `@tnotify-shell-integration` off and rely on the default polling mode.

> \[!NOTE]\
> On zsh and fish, the command line that just finished is also exposed to user hooks via `TMUX_NOTIFY_COMMAND` (see [Execute custom user commands](#execute-custom-user-commands)). Bash doesn't expose this — `TMUX_NOTIFY_COMMAND` will be empty there.

## How does it work

By default, a naive polling approach: every few seconds the plugin captures the pane contents and checks whether the last line looks like a shell prompt (see [Add additional shell suffixes](#add-additional-shell-suffixes)).

With `@tnotify-shell-integration 'on'`, polling is replaced by a `precmd` / `PROMPT_COMMAND` / `fish_postexec` hook in your shell that fires the notification directly when the next prompt is drawn. See [Shell-hook detection](#shell-hook-detection-zsh--bash--fish).

## Other use cases

### Use inside a docker container

Because tmux-notify uses [libnotify](https://gitlab.gnome.org/GNOME/libnotify) to send notifications, it needs access to the host's D-Bus socket. An excellent guide on how to do this can be found [here](https://github.com/mviereck/x11docker/wiki/How-to-connect-container-to-DBus-from-host#dbus-user-session-daemon). You can also check out the [examples/docker](examples/docker/README.md) folder for an example.

## Contributing

Feel free to open an issue if you have ideas on how to make this GitHub action better or if you want to report a bug! All contributions are welcome :rocket:. Please consult the [contribution guidelines](CONTRIBUTING.md) for more information.

## References

*   The initial version of this tool was developed by [@ChanderG](https://github.com/ChanderG).
*   Icon created with svg made by [@chanut](https://www.flaticon.com/authors/chanut) from [www.flaticon.com](https://www.flaticon.com/authors/chanut)
