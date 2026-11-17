#!/bin/bash
set -u

LABEL="local.skif-wifi-login"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null
rm -f "$PLIST" "$HOME/.local/bin/skif-wifi-login.sh"
rm -rf "$HOME/Library/Application Support/skif-wifi"
echo "Uninstalled. Logs left at ~/Library/Logs/skif-wifi-login.*"
