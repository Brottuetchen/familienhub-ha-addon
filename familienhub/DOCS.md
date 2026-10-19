# Familienhub add-on

Runs the [Familienhub](https://github.com/Brottuetchen/familienhub) server (FastAPI backend and the web app in one image) as a Home Assistant add-on. It uses a SQLite database in the add-on's `/data` folder instead of PostgreSQL, which is plenty for one household.

## Install

1. In Home Assistant open **Settings -> Add-ons -> Add-on store**.
2. Open the menu (three dots, top right) -> **Repositories** and add `https://github.com/Brottuetchen/familienhub-ha-addon`. Or use the "Add repository" button in the repository README.
3. Install **Familienhub**. The first install builds the add-on image on your Home Assistant from the published Familienhub image; this takes a minute and needs internet access.
4. Review the options, start the add-on and open `http://<home-assistant-address>:8000` (or **Open web UI**).

## First start

A new hub shows **Set up**. The first person to open it creates the admin account; the setup wizard then guides through basics, services and inviting the family. This works only while no admin exists.

If Home Assistant is reachable from the internet, turn on **Require setup code** before the first start: the code is written to the add-on log and is needed to create the admin.

## Options

| Option | Default | Meaning |
|---|---|---|
| `timezone` | `Europe/Berlin` | Time zone of the household (IANA name). |
| `log_level` | `info` | `debug`, `info`, `warning` or `error`. |
| `setup_require_code` | `false` | Require the setup code from the log to create the first admin. |
| `secure_cookies` | `false` | Only with HTTPS-only access (reverse proxy). Plain HTTP on the LAN needs `false`. |
| `public_url` | empty | Address people use, e.g. `https://hub.example.org`. Used for links in notifications (`HUB_PUBLIC_URL`). |
| `cors_origins` | empty | Leave empty unless a web page on another address calls the API. |
| `plugins_disabled` | empty | Comma-separated plugin IDs to switch off, e.g. `weather`. |
| `oidc_issuer`, `oidc_client_id`, `oidc_client_secret`, `oidc_auto_create` | empty / `false` | Optional sign-in with Authentik, Keycloak etc. Needs `public_url`; the redirect address `<public_url>/api/auth/oidc/callback` is derived from it and must be registered at the provider. |

Everything else (Nextcloud, Home Assistant, Paperless, Seerr, ntfy, weather ...) is configured as admin in the app under **More -> Administration -> Plugins & access**, without restart. To connect Familienhub to your Home Assistant, create a long-lived access token in your HA profile and enter it there.

Settings that are not add-on options (Firebase push, VAPID keys, downloads folder) are not exposed. Web Push works out of the box; its keys are created once in `/data/vapid.json`.

## Data and backups

Everything lives in `/data` of the add-on:

- `familienhub.db`: the SQLite database (people, settings, hub-internal tasks, shopping list, calendar).
- `secret_key`: generated on first start, signs sign-in tokens and encrypts stored plugin credentials. If it is lost, stored credentials cannot be decrypted and everyone is signed out.
- `vapid.json`: Web Push keys.

Home Assistant backups include this folder automatically. The add-on is set to a cold backup mode: it is stopped briefly while the backup is taken so the database is consistent. Restore a backup of the add-on to get the same data, including the secret key.

## Updating

The add-on version is the Familienhub version. When an update appears in the add-on store, read the changelog and update; the database migrates automatically on start. Back up first (**Settings -> System -> Backups**).

## Mobile apps

The Android and iOS apps are not part of the add-on. Get them from the [Familienhub releases](https://github.com/Brottuetchen/familienhub/releases/latest) and enter the add-on's address (`http://<home-assistant-address>:8000`, or your HTTPS address) when the app asks for the server. The phone must reach that address (home Wi-Fi, VPN such as WireGuard or Tailscale, or a reverse proxy). Alternatively open the web app in Safari and use *Add to Home Screen*.

## Why no Home Assistant sidebar (ingress)?

Ingress serves an add-on under a changing path prefix (`/api/hassio_ingress/<token>/`). The Familienhub web app is built for the root path `/`: its base address, service worker (`/push-sw.js`) and API calls are absolute, and push and sign-in cookies would not work in the ingress frame. Rather than offer an unreliable sidebar panel, the add-on exposes port 8000 and a web UI link. To put it into the HA sidebar anyway, add a *webpage* dashboard pointing at the hub's HTTPS address.

## Security notes

- Without HTTPS the traffic stays on your LAN in plain text. For access from outside use a VPN or a reverse proxy with HTTPS (then set `secure_cookies` and `public_url`). Do not forward port 8000 to the internet without HTTPS.
- Sign-in uses bcrypt passwords or OIDC; credentials for other services are stored encrypted; short-lived tokens. Roles: admin, partner, child, guest, enforced on the server.
- Plugins installed from GitHub run inside the hub with full access. Only admins can install them; install only plugins you trust.
- Treat `/data` (and backups containing it) as sensitive: whoever can read `secret_key` can forge sign-in tokens.
- Report vulnerabilities privately via GitHub's advisory (Security -> Report a vulnerability) in the main repository. Details: [security docs](https://github.com/Brottuetchen/familienhub/blob/main/docs/security.md).

## Differences to the Docker Compose setup

SQLite instead of PostgreSQL, no separate database container, and a reduced set of options. To move to PostgreSQL later, use the Docker Compose setup; there is no automatic migration of the SQLite file.
