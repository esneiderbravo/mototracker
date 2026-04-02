#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")/.."

# Watches lib/i18n/*.i18n.json and regenerates generated Dart localization files.
dart run slang watch

