# skif-tim-g9-wifi-login

Stops the SKIF Group guest Wi-Fi at Tim Hortons G-9 from logging you out every hour. macOS only.

## The problem

The hotspot (a MikroTik router at `172.25.2.1`) ends your session every hour. To get back online you go through a portal that asks for your name and phone number, then shows an "OTP sent via SMS" screen with a **Continue now** button.

None of that is checked. No SMS is ever sent, and the router never sees your name or number. The **Continue now** button posts a fixed username and password (`987` / `786`) to the router, the same for everyone. That's the only real login.

## What this does

It skips the portal and sends `987` / `786` straight to the router. A LaunchAgent runs `skif-tim-g9-wifi-login.sh` every 60 seconds. On each run:

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
./dotfiles/utils/skif-tim-g9-wifi-login/install.sh
```

Or copy just this folder and run `./install.sh`. The installer copies the script to `~/.local/bin/` and loads a LaunchAgent named `local.skif-tim-g9-wifi-login`. After that you can delete the folder.

## When it fails

If logging in doesn't get you online, you get a macOS notification saying why. You get one per failure, not one every minute:

| Notification | Meaning |
|---|---|
| `987/786 was rejected…` | SKIF changed the shared login. See below |
| `Logged in, but there's no internet…` | The login worked, but SKIF's internet is down. Nothing to fix on your end |
| `Can't reach the hotspot router…` | The router isn't answering, or you're not really on this network |

**Finding the new login:** go through the portal in a browser. On the "Continue now" page, use View Source and look for the hidden `username` and `password` inputs. Put the new values in `HS_USER` / `HS_PASS` at the top of the script and run `./install.sh` again.

## Check it's working

```bash
tail -f ~/Library/Logs/skif-tim-g9-wifi-login.log
```

A line is written only when it does something:

- `proactive session refresh`: renewed the session early (about every 50 min). This is normal.
- `re-login after dropout: OK`: you were logged out and it got you back in.
- `FAILED: …`: see When it fails.

## Uninstall

```bash
./uninstall.sh
```

## Troubleshooting

- **`re-login after dropout` every hour:** the hotspot's session is shorter than 50 min. Lower `REFRESH_SECS` in the script and run `./install.sh` again.
- **Nothing happens at all:** with a VPN that takes over the default route (for example a Tailscale exit node), the gateway check doesn't match and the script stays idle.
