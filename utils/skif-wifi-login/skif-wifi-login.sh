#!/bin/bash
# Keeps a SKIF Group (MikroTik) hotspot session alive. Does nothing on other networks.
set -u

GATEWAY="172.25.2.1"
LOGIN_URL="http://$GATEWAY/login"
HS_USER="987"
HS_PASS="786"
REFRESH_SECS=3000   # must stay under the hotspot's 1h session timeout

STATE="$HOME/Library/Application Support/skif-wifi/last-login"
LOG="$HOME/Library/Logs/skif-wifi-login.log"

ts() { date "+%Y-%m-%d %H:%M:%S"; }

do_login() {
  curl -s -m 10 \
    --data-urlencode "username=$HS_USER" \
    --data-urlencode "password=$HS_PASS" \
    --data-urlencode "domain=" \
    --data-urlencode "dst=http://www.google.com/" \
    "$LOGIN_URL" >/dev/null 2>&1
}

online() {
  curl -s -m 5 "http://captive.apple.com/hotspot-detect.html" 2>/dev/null | grep -q "Success"
}

cur_gw=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')
[ "$cur_gw" = "$GATEWAY" ] || exit 0

mkdir -p "$(dirname "$STATE")"
now=$(date +%s)
last=0
[ -f "$STATE" ] && last=$(cat "$STATE" 2>/dev/null || echo 0)
age=$(( now - last ))

if ! online; then
  do_login
  if online; then
    echo "$now" > "$STATE"
    echo "$(ts) re-login after dropout: OK" >> "$LOG"
  else
    echo "$(ts) login attempt FAILED" >> "$LOG"
  fi
elif [ "$age" -ge "$REFRESH_SECS" ]; then
  do_login
  echo "$now" > "$STATE"
  echo "$(ts) proactive session refresh (prev age ${age}s)" >> "$LOG"
fi
