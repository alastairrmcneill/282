#!/usr/bin/env bash
# Shared config for Mapbox style pull/push scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USERNAME="alastairm94"

style_id() {
  case "$1" in
    light) echo "cmrabh9j4003r01r08baw5o6a" ;;
    dark)  echo "cmpdpqwg2000001siaqwm3zx5" ;;
    *) echo "unknown style: $1 (expected 'light' or 'dark')" >&2; exit 1 ;;
  esac
}

style_file() {
  echo "$SCRIPT_DIR/two_eight_two_$1.json"
}

token() {
  if [[ -n "${MAPBOX_SECRET_TOKEN:-}" ]]; then
    echo "$MAPBOX_SECRET_TOKEN"
  elif [[ -f "$SCRIPT_DIR/.secret_token" ]]; then
    cat "$SCRIPT_DIR/.secret_token"
  else
    echo "No token: set MAPBOX_SECRET_TOKEN or create $SCRIPT_DIR/.secret_token" >&2
    echo "(needs an sk.* token with styles:read + styles:write scopes)" >&2
    exit 1
  fi
}
