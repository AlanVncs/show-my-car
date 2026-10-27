# Show my vehicle

Ask for your vehicle and a pin appears on it. The pin follows the vehicle and removes itself when you get in or when you arrive. Each player has their own pin.

Packaging, tests, and upload to the mod portal come from the mod template.

## What is included

- `info.json`, `control.lua`, `data.lua`, `settings.lua`, `vehicle_rules.lua`, `changelog.txt`, locale files, and a thumbnail
- `.modfiles`, the list of paths that go into the release zip
- Unit tests that run outside the game, including the template's release-file checks and the pin rules
- A GitHub Actions workflow that tests pull requests and, on `main`, checks the portal before tests and packaging
- A project skill so an AI assistant can explain the layout, configure the portal key, and prepare a release

Factorio 2.1 is the version this mod targets. English and Brazilian Portuguese locales are included.

## Ready to use with AI

The skill at `.cursor/skills/factorio-mod-template/SKILL.md` is project guidance the assistant loads when you ask about the file layout or the portal key, or ask to publish or prepare a version.

The skill covers:

- The role of each file, including locale, changelog format, and `.modfiles`
- How to create a Factorio API key and store it as the GitHub Actions secret `FACTORIO_API_KEY`
- How to prepare a release: require a clean git tree, compare the repository with the last version on the mod portal, bump `info.json` and `changelog.txt`, and show a commit message

The assistant does not stage, commit, or push until you confirm. Answering "yes" is the confirmation to finish the release.

## How this mod is set up

1. The internal name is `show-my-vehicle`, in `info.json`, in the locale files and their sections, and in the locale keys used by the scripts.
2. The folder inside `mods/` is that internal name, or `show-my-vehicle_version`.
3. Create an API key at [factorio.com/profile](https://factorio.com/profile) under **API Keys**. Store it in the GitHub repository as an Actions secret named `FACTORIO_API_KEY`.
4. Push to `main`. The workflow checks the portal first. A version that is already published is left as it is, and the workflow succeeds without tests or packaging. Otherwise it runs the tests and, when they pass, uploads the zip to the portal.

A pattern in `.modfiles` that matches nothing stops the package step, so the zip only contains files you listed.
