#!/usr/bin/env bash
# Copies all public schema data from 282 Prod → 282 Dev.
# Pure merge: dev rows kept on conflict (ON CONFLICT DO NOTHING).
# Excludes: user_fcm_tokens (environment-specific).
#
# SETUP:
#   1. Get both passwords from Supabase Dashboard → [project] → Settings → Database
#      → "Connection string" tab → Direct connection (port 5432)
#   2. Either set the env vars before running:
#        export PROD_DB_PASSWORD="..."
#        export DEV_DB_PASSWORD="..."
#        ./scripts/migrate_prod_to_dev.sh
#      Or hardcode below (don't commit the file if you do this):
#        PROD_DB_PASSWORD="your-prod-password"
#        DEV_DB_PASSWORD="your-dev-password"

set -euo pipefail

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

PROD_HOST="db.bzzdszqqstspbzyclwxh.supabase.co"
DEV_HOST="db.pqgaczyxzxopkgyjqudk.supabase.co"
DB_PORT="5432"
DB_NAME="postgres"
DB_USER="postgres"

if [[ -z "${PROD_DB_PASSWORD:-}" ]]; then
  echo "Error: PROD_DB_PASSWORD not set."
  echo "Get it from: Supabase Dashboard → 282 Prod → Settings → Database → Connection string"
  exit 1
fi
if [[ -z "${DEV_DB_PASSWORD:-}" ]]; then
  echo "Error: DEV_DB_PASSWORD not set."
  echo "Get it from: Supabase Dashboard → 282 Dev → Settings → Database → Connection string"
  exit 1
fi

PROD_URL="postgresql://${DB_USER}:${PROD_DB_PASSWORD}@${PROD_HOST}:${DB_PORT}/${DB_NAME}"
DEV_URL="postgresql://${DB_USER}:${DEV_DB_PASSWORD}@${DEV_HOST}:${DB_PORT}/${DB_NAME}"

DUMP_FILE="/tmp/282_prod_data.sql"
IMPORT_FILE="/tmp/282_prod_data_import.sql"

echo "==> Dumping prod data (this may take a few minutes)..."
pg_dump \
  --data-only \
  --disable-triggers \
  --inserts \
  --on-conflict-do-nothing \
  --schema=public \
  --exclude-table=public.user_fcm_tokens \
  "$PROD_URL" > "$DUMP_FILE"

echo "==> Dump complete. Rows in dump: $(grep -c '^INSERT' "$DUMP_FILE" || true)"

echo "==> Wrapping with FK/trigger bypass..."
{
  echo "SET session_replication_role = 'replica';"
  cat "$DUMP_FILE"
  echo "SET session_replication_role = 'origin';"
} > "$IMPORT_FILE"

echo "==> Importing into dev (this may take several minutes)..."
psql "$DEV_URL" -f "$IMPORT_FILE"

echo ""
echo "==> Done. Row counts in dev:"
psql "$DEV_URL" -c "
SELECT relname AS table, n_live_tup AS approx_rows
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC;
"

echo ""
echo "==> Cross-check prod counts:"
psql "$PROD_URL" -c "
SELECT relname AS table, n_live_tup AS approx_rows
FROM pg_stat_user_tables
WHERE schemaname = 'public' AND relname != 'user_fcm_tokens'
ORDER BY n_live_tup DESC;
"

rm -f "$DUMP_FILE" "$IMPORT_FILE"
echo "==> Temp files cleaned up."
