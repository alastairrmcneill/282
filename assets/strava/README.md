# Strava brand assets

Strava's Brand Guidelines require the official, unmodified "Connect with Strava"
button and "Powered by Strava" logo. They can't be redistributed in this repo by
an automated tool, so download them from https://developers.strava.com/guidelines/
and put these files in this folder (names must match exactly):

| File | Used by |
| --- | --- |
| `btn_strava_connect_with_orange.png` (+ `2.0x/`, `3.0x/` variants) | `ConnectWithStravaButton` |
| `api_logo_pwrdBy_strava_horiz_orange.png` (+ `2.0x/`, `3.0x/` variants) | `PoweredByStravaLogo` (light mode) |
| `api_logo_pwrdBy_strava_horiz_white.png` (+ `2.0x/`, `3.0x/` variants) | `PoweredByStravaLogo` (dark mode) |

Until they're added, the widgets fall back to plain text so the app doesn't
crash. **Don't ship with the fallbacks**: they don't meet the guidelines.
