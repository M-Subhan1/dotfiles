#!/bin/bash
# Keeps the SKIF Group hotspot session at Tim Hortons G-9 alive. Does nothing on other networks.
set -u

NAME="skif-tim-g9-wifi-login"
GATEWAY="172.25.2.1"
LOGIN_URL="http://$GATEWAY/login"
HS_USER="987"
HS_PASS="786"
REFRESH_SECS=3000   # must stay under the hotspot's 1h session timeout

STATE_DIR="$HOME/Library/Application Support/$NAME"
LAST="$STATE_DIR/last-login"
FAILED="$STATE_DIR/failed"
LOG="$HOME/Library/Logs/$NAME.log"

ts() { date "+%Y-%m-%d %H:%M:%S"; }

online() {
  curl -s -m 5 "http://captive.apple.com/hotspot-detect.html" 2>/dev/null | grep -q "Success"
}

# Prints the router's response; empty if the router didn't answer.
do_login() {
  curl -s -m 10 \
    --data-urlencode "username=$HS_USER" \
    --data-urlencode "password=$HS_PASS" \
    --data-urlencode "domain=" \
    --data-urlencode "dst=http://www.google.com/" \
    "$LOGIN_URL" 2>/dev/null
}

# Only the first failure in a streak notifies, since this runs every minute.
fail() {
  echo "$(ts) FAILED: $1" >> "$LOG"
  [ -f "$FAILED" ] && return
  touch "$FAILED"
  osascript -e "display notification \"$1\" with title \"Wi-Fi auto-login failed\"" 2>/dev/null
}

succeed() {
  date +%s > "$LAST"
  rm -f "$FAILED"
  echo "$(ts) $1" >> "$LOG"
}

cur_gw=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')
[ "$cur_gw" = "$GATEWAY" ] || exit 0

mkdir -p "$STATE_DIR"
now=$(date +%s)
last=0
[ -f "$LAST" ] && last=$(cat "$LAST" 2>/dev/null || echo 0)
age=$(( now - last ))

if online; then
  [ "$age" -ge "$REFRESH_SECS" ] || exit 0
  do_login >/dev/null
  succeed "proactive session refresh (prev age ${age}s)"
  exit 0
fi

resp=$(do_login)
if online; then
  succeed "re-login after dropout: OK"
elif [ -z "$resp" ]; then
  fail "Can't reach the hotspot router at $GATEWAY."
elif echo "$resp" | grep -qE "hotspot_status|You are logged in"; then
  fail "Logged in, but there's no internet. SKIF's connection is probably down."
else
  fail "$HS_USER/$HS_PASS was rejected. The shared login was probably changed (see README)."
fi
