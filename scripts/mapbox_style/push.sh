#!/usr/bin/env bash
# Restore a versioned style JSON file to Mapbox Studio (overwrites the live style).
# Usage: ./push.sh [light|dark|all]   (default: all)
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

push() {
  local name="$1" id file response
  id="$(style_id "$name")"
  file="$(style_file "$name")"
  [[ -f "$file" ]] || { echo "missing $file — run pull.sh first" >&2; exit 1; }
  response="$(jq 'del(.created, .modified)' "$file" \
    | curl -sf -X PATCH "https://api.mapbox.com/styles/v1/$USERNAME/$id?access_token=$(token)" \
        -H "Content-Type: application/json" --data @-)"
  echo "pushed $name -> live (modified: $(echo "$response" | jq -r .modified))"
}

case "${1:-all}" in
  all) push light; push dark ;;
  *)   push "$1" ;;
esac
