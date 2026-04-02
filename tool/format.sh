#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")/.."

dart format lib test tool

