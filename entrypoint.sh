#!/usr/bin/env bash
set -euo pipefail

umask 077

if [[ ! -d /work ]]; then
  echo "error: /work is missing; bind-mount a writable work directory." >&2
  exit 1
fi

if [[ ! -w /work ]]; then
  echo "error: /work is not writable; bind-mount a writable work directory." >&2
  exit 1
fi

exec codex "$@"
