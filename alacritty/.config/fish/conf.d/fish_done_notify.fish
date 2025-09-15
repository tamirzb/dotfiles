# Use a custom notification script so that if the notification is clicked the
# underlying alacritty terminal is focused
set __done_notification_command "~/.config/alacritty/terminal_notify.py --always-show \$title \$message"
