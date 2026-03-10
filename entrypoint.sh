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

# Force codex state under /work
export HOME=/work
export CODEX_HOME=/work/.codex

mkdir -p "${CODEX_HOME}"
cp /home/ubuntu/AGENTS.md $CODEX_HOME/AGENTS.md
if [[ "$#" -eq 0 ]]; then
  exec /bin/bash -l
fi

exec /bin/bash "$@"
