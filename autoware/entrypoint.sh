#!/usr/bin/env bash
set -e

MAP_DIR="${MAP_DIR:-${HOME}/autoware_map}"
DEFAULT_MAP="Monash_Clayton_campus_simulation_only"
DEFAULT_MAP_ROOT="$MAP_DIR/$DEFAULT_MAP"
MAP_ZIP="${MAP_DIR}/${DEFAULT_MAP}.zip"
MAP_URL="https://github.com/Monash-Connected-Autonomous-Vehicle/autoware-maps/releases/download/v1.0.0/Monash_Clayton_campus_simulation_only.zip"
MAP_ZIP_SHA256="e0747f96197d4b6090d0dfbd2baa337cd70d8305e0f38c024709e3cf22dfa41b"
ENABLE_VNC="${ENABLE_VNC:-false}"

if [ ! -d "$DEFAULT_MAP_ROOT" ]; then
  mkdir -p "$MAP_DIR"
  wget -O "$MAP_ZIP" "$MAP_URL"
  echo "${MAP_ZIP_SHA256}  ${MAP_ZIP}" | sha256sum -c -
  unzip -o -d "$MAP_DIR" "$MAP_ZIP"
fi

if [ "$ENABLE_VNC" = "true" ]; then
  export DISPLAY="${DISPLAY:-:1}"
  /start_vnc.sh &
fi

if [ $# -gt 0 ]; then
  exec "$@"
fi

sleep infinity
