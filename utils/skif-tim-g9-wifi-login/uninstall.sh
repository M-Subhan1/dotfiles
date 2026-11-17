#!/bin/bash
set -u

NAME="skif-tim-g9-wifi-login"
PLIST="$HOME/Library/LaunchAgents/local.$NAME.plist"

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null
rm -f "$PLIST" "$HOME/.local/bin/$NAME.sh"
rm -rf "$HOME/Library/Application Support/$NAME"
echo "Uninstalled. Logs left at ~/Library/Logs/$NAME.*"
