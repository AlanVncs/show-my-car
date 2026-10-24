#!/usr/bin/env bash
# Builds a Factorio mod-portal zip: {name}_{version}/{name}_{version}/...
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -f info.json ]]; then
  echo "info.json not found in $ROOT" >&2
  exit 1
fi

read -r NAME VERSION < <(python3 -c 'import json; info = json.load(open("info.json")); print(info["name"], info["version"])')

if [[ -z "$NAME" || -z "$VERSION" ]]; then
  echo "info.json must define name and version" >&2
  exit 1
fi

ARCHIVE_NAME="${NAME}_${VERSION}"
OUT_DIR="$ROOT/dist"
ZIP_PATH="$OUT_DIR/${ARCHIVE_NAME}.zip"
STAGE="$(mktemp -d)"

cleanup() {
  rm -rf "$STAGE"
}
trap cleanup EXIT

mkdir -p "$OUT_DIR" "$STAGE/$ARCHIVE_NAME"

# Portal zip must contain exactly one top-level folder named name_version.
# Packaging output and editor files stay out of the archive.
tar -C "$ROOT" \
  --exclude='./dist' \
  --exclude='./.git' \
  --exclude='./.cursor' \
  --exclude='./package.sh' \
  --exclude='./*.zip' \
  --exclude='./gallery.jpg' \
  --exclude='./hero.png' \
  --exclude='./screenshots' \
  -cf - . \
  | tar -C "$STAGE/$ARCHIVE_NAME" -xf -

rm -f "$ZIP_PATH"
(
  cd "$STAGE"
  zip -qr "$ZIP_PATH" "$ARCHIVE_NAME"
)

echo "Created $ZIP_PATH"
unzip -l "$ZIP_PATH"
