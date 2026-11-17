# skif-wifi-login

Stops the SKIF Group guest Wi-Fi from logging you out every hour. macOS only.

## The problem

The hotspot (a MikroTik router at `172.25.2.1`) ends your session every hour. To get back online you go through a portal that asks for your name and phone number, then shows an "OTP sent via SMS" screen with a **Continue now** button.

There is no real OTP. That button posts a fixed username and password (`987` / `786`) to the router, the same for everyone. The name/phone step doesn't need to succeed for the login to work.

## What this does

A LaunchAgent runs `skif-wifi-login.sh` every 60 seconds. On each run:

| Situation | Action |
|---|---|
| Not on this network (default gateway isn't `172.25.2.1`) | Nothing |
| On it, logged out | Logs in again, so a dropout lasts at most about a minute |
| On it, online, session older than 50 min | Logs in again early, before the 1-hour cutoff, so you never drop |

Logging in again while already online doesn't interrupt the connection. In testing, 139 probes in a row succeeded across a refresh.

It keeps running across sleep, restarts and network changes, and doesn't need sudo.

## Install

```bash
git clone https://github.com/M-Subhan1/dotfiles.git
./dotfiles/utils/skif-wifi-login/install.sh
```

Or copy just this folder and run `./install.sh`. The installer copies the script to `~/.local/bin/` and loads a LaunchAgent named `local.skif-wifi-login`. After that you can delete the folder.

## Check it's working

```bash
tail -f ~/Library/Logs/skif-wifi-login.log
```

A line is written only when it does something:

- `proactive session refresh`: renewed the session early (about every 50 min). This is normal.
- `re-login after dropout: OK`: you were logged out and it got you back in.
- `login attempt FAILED`: see Troubleshooting.

## Uninstall

```bash
./uninstall.sh
```

## Troubleshooting

- **`re-login after dropout` every hour:** the hotspot's session is shorter than 50 min. Lower `REFRESH_SECS` in the script and run `./install.sh` again.
- **`login attempt FAILED`:** the shared credentials have probably changed. Log out, go through the portal in a browser, and on the "Continue now" page use View Source to read the new values from the hidden `username` and `password` inputs. Update `HS_USER` / `HS_PASS` and run `./install.sh` again.
- **Nothing happens at all:** with a VPN that takes over the default route (for example a Tailscale exit node), the gateway check doesn't match and the script stays idle.
- **A different SKIF venue:** the gateway or credentials may be different. Find them the same way and edit the variables at the top of the script.
