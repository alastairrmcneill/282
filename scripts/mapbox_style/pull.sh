#!/usr/bin/env bash
# Snapshot the live Mapbox Studio styles into versioned JSON files.
# Usage: ./pull.sh [light|dark|all]   (default: all)
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

pull() {
  local name="$1" id file
  id="$(style_id "$name")"
  file="$(style_file "$name")"
  # fresh=true bypasses the CDN cache; created/modified churn on every save, so drop
  # them for clean git diffs. Sort keys so diffs are stable.
  curl -sf "https://api.mapbox.com/styles/v1/$USERNAME/$id?access_token=$(token)&fresh=true" \
    | jq -S 'del(.created, .modified)' > "$file"
  echo "pulled $name -> $file ($(wc -c < "$file" | tr -d ' ') bytes)"
}

case "${1:-all}" in
  all) pull light; pull dark ;;
  *)   pull "$1" ;;
esac
