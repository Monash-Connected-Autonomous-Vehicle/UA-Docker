#!/usr/bin/env bash
set -euo pipefail

if [ "${ENABLE_VNC:-false}" = "true" ]; then
  export DISPLAY="${DISPLAY:-:1}"
  /start_vnc.sh &
fi

exec "$@"
