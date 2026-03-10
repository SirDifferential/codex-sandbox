#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 /host/workdir [extra docker args...]" >&2
  exit 2
fi

KEY=`cat ~/.codex-key`

HOST_WORKDIR="$1"
shift

if [[ ! -d "${HOST_WORKDIR}" ]]; then
  echo "error: host workdir does not exist: ${HOST_WORKDIR}" >&2
  exit 1
fi

IMAGE_NAME="${IMAGE_NAME:-codex-sandbox:latest}"
RUN_UID="${RUN_UID:-$(id -u)}"
RUN_GID="${RUN_GID:-$(id -g)}"
EXTRA_ENTRYPOINT=()
CMD_ARGS=()

if [[ "$#" -eq 0 ]]; then
  EXTRA_ENTRYPOINT=(--entrypoint /bin/bash)
  CMD_ARGS=(-l)
fi

docker run --rm -it \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,nodev \
  --tmpfs /var/tmp:rw,noexec,nosuid,nodev \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --env OPENAI_API_KEY=$KEY \
  --pids-limit=256 \
  --memory=6g \
  --cpus=8 \
  --user="${RUN_UID}:${RUN_GID}" \
  --env HOME=/work \
  --mount type=bind,src="${HOST_WORKDIR}",dst=/work,readonly=false \
  "${EXTRA_ENTRYPOINT[@]}" \
  "$@" \
  "${IMAGE_NAME}" \
  "${CMD_ARGS[@]}"
