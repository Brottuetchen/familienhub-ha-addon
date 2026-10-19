# Familienhub add-on repository for Home Assistant

[![Add repository to my Home Assistant][badge]][add]

Home Assistant add-on for [Familienhub](https://github.com/Brottuetchen/familienhub), a self-hosted family hub (calendar, tasks, shopping list, meals, reminders) with web app and Android/iOS apps.

## Install

1. Click the badge above (or in Home Assistant: **Settings -> Add-ons -> Add-on store -> menu -> Repositories** and add `https://github.com/Brottuetchen/familienhub-ha-addon`).
2. Install **Familienhub**, start it and open `http://<home-assistant-address>:8000`.
3. Create the admin account on first start.

Setup, options, backups and security notes: [familienhub/DOCS.md](familienhub/DOCS.md).

## Add-ons

| Add-on | Description |
|---|---|
| [Familienhub](familienhub/) | Server and web app (SQLite, data in `/data`) |

## Maintenance: version bumps

The add-on version equals the Familienhub image tag (`ghcr.io/brottuetchen/familienhub:<version>`). For each Familienhub release:

1. Set `version` in `familienhub/config.yaml` to the new tag (without `v`), e.g. `1.0.0`.
2. Set the `ARG BUILD_VERSION` default in `familienhub/Dockerfile` to the same value (the Supervisor overrides it with the add-on version; the default is for manual builds).
3. Add an entry to `familienhub/CHANGELOG.md`.
4. Commit, push to `main`. Home Assistant shows the update once the new version is on `main`. Make sure the image tag exists in the registry first.

## Development

The lint workflow runs the Home Assistant add-on linter and a YAML check on every push and pull request. Locally: `python -c "import yaml,sys; [yaml.safe_load(open(f)) for f in sys.argv[1:]]" repository.yaml familienhub/config.yaml familienhub/translations/*.yaml`.

## License

AGPL-3.0, see [LICENSE](LICENSE), same as Familienhub.

[badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[add]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FBrottuetchen%2Ffamilienhub-ha-addon
