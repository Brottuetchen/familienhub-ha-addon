# Changelog

## 1.0.0-beta.2

- Based on the Familienhub image `ghcr.io/brottuetchen/familienhub:1.0.0-beta.2`.
- New in Familienhub: plugin and theme store, customisable Today screen, backup and restore, update notice, recipe import from a link, kids mode (stars and rewards), birthdays, timetable for children, template lists, voice assistant via Home Assistant Assist. Full list: https://github.com/Brottuetchen/familienhub/blob/main/CHANGELOG.md
- The database migrates on start. Make a Home Assistant backup of the add-on before updating.

## 1.0.0-beta.1

- First release of the add-on, based on the Familienhub image `ghcr.io/brottuetchen/familienhub:1.0.0-beta.1`.
- SQLite database, generated secret key and Web Push keys are kept in `/data`.
- Options: time zone, log level, setup code, secure cookies, public address, CORS, disabled plugins, OIDC.
