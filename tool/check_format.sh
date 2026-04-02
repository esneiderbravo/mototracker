#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")/.."

dart format --output=none --set-exit-if-changed lib test tool

