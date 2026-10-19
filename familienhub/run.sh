#!/bin/bash
# Start script of the Familienhub add-on. Does not need bashio: options are read from
# /data/options.json with Python, which the upstream image ships.
set -euo pipefail

OPTIONS=/data/options.json
DATA=/data
UID_APP=10001

# Turn options.json into shell exports. Values are quoted, nothing is evaluated from them.
# Empty options are skipped so that the application defaults apply.
if [ -f "$OPTIONS" ]; then
  eval "$(python - "$OPTIONS" <<'PY'
import json, shlex, sys

opts = json.load(open(sys.argv[1], encoding="utf-8"))
mapping = {
    "timezone": "TIMEZONE",
    "log_level": "LOG_LEVEL",
    "setup_require_code": "SETUP_REQUIRE_CODE",
    "secure_cookies": "SECURE_COOKIES",
    "public_url": "HUB_PUBLIC_URL",
    "cors_origins": "CORS_ORIGINS",
    "plugins_disabled": "PLUGINS_DISABLED",
    "oidc_issuer": "OIDC_ISSUER",
    "oidc_client_id": "OIDC_CLIENT_ID",
    "oidc_client_secret": "OIDC_CLIENT_SECRET",
    "oidc_auto_create": "OIDC_AUTO_CREATE",
}
for key, env in mapping.items():
    value = opts.get(key)
    if value is None or value == "":
        continue
    if isinstance(value, bool):
        value = "true" if value else "false"
    print("export %s=%s" % (env, shlex.quote(str(value))))
PY
)"
fi

# With a public address, the OIDC redirect URIs follow from it
if [ -n "${HUB_PUBLIC_URL:-}" ] && [ -n "${OIDC_ISSUER:-}" ]; then
  HUB_PUBLIC_URL="${HUB_PUBLIC_URL%/}"
  export HUB_PUBLIC_URL
  export OIDC_REDIRECT_URI_WEB="${HUB_PUBLIC_URL}/api/auth/oidc/callback"
  export OIDC_REDIRECT_URI_APP="${HUB_PUBLIC_URL}/api/auth/oidc/callback"
fi

export ENVIRONMENT=production
export DATA_DIR="$DATA"
# Four slashes = absolute path
export DATABASE_URL="sqlite:////data/familienhub.db"

# Generate the SECRET_KEY once and keep it in /data (same file the application uses itself).
# It signs sign-in tokens and encrypts stored credentials: never delete it, it is part of the backup.
umask 077
if [ ! -s "$DATA/secret_key" ]; then
  python -c 'import secrets; print(secrets.token_urlsafe(48), end="")' > "$DATA/secret_key"
  echo "Generated a new secret key in $DATA/secret_key"
fi
# The application owns everything in /data except options.json, which belongs to the Supervisor
find "$DATA" -mindepth 1 ! -name options.json -exec chown "$UID_APP:$UID_APP" {} +
# The data directory itself must be writable for the application user (SQLite journal files)
chown "$UID_APP:$UID_APP" "$DATA"

LEVEL="${LOG_LEVEL:-info}"
echo "Starting Familienhub (log level: $LEVEL, data: $DATA)"
exec setpriv --reuid="$UID_APP" --regid="$UID_APP" --clear-groups \
  uvicorn app.main:app --host 0.0.0.0 --port 8000 --log-level "$LEVEL"
