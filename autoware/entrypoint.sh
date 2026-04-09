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

# Set default overrides to Autoware vehicle parameters so that simulations drive like Twizy
# This doesn't prevent further overrides within the container (e.g. when building & sourcing launch files in the container)
set_param () {
  local FILE=$1
  local KEY=$2
  local VALUE=$3

  if [ ! -f "$FILE" ]; then
    echo "ERROR: File not found: $FILE"
    exit 1
  fi

  local current
  current="$(yq e "$KEY" "$FILE")"
  if [ "$current" = "null" ] || [ -z "$current" ]; then
    echo "ERROR: Key not found: $KEY in $FILE"
    exit 1
  fi

  yq e "$KEY = $VALUE" -i "$FILE"
  echo "Updated $KEY → $VALUE"
}

# Derived from: https://github.com/Monash-Connected-Autonomous-Vehicle/autoware_launch.twizy/blob/mcav-0.45.3/autoware_launch/config/planning/scenario_planning/common/common.param.yaml
common_param_file="/opt/autoware/share/autoware_launch/config/planning/scenario_planning/common/common.param.yaml"
set_param $common_param_file '.["/**"].ros__parameters.max_vel' '11.1'
set_param $common_param_file '.["/**"].ros__parameters.normal.min_acc' '-1.5'
set_param $common_param_file '.["/**"].ros__parameters.normal.max_acc' '1.5'

# Derived from: https://github.com/Monash-Connected-Autonomous-Vehicle/autoware_launch.twizy/blob/mcav-0.45.3/vehicle/twizy_vehicle_launch/twizy_vehicle_description/config/vehicle_info.param.yaml
vehicle_info_file="/opt/autoware/share/sample_vehicle_description/config/vehicle_info.param.yaml"
set_param $vehicle_info_file '.["/**"].ros__parameters.wheel_radius' '0.2725' 
set_param $vehicle_info_file '.["/**"].ros__parameters.wheel_width' '0.146'
set_param $vehicle_info_file '.["/**"].ros__parameters.wheel_base' '1.68'
set_param $vehicle_info_file '.["/**"].ros__parameters.wheel_tread' '1.095'
set_param $vehicle_info_file '.["/**"].ros__parameters.front_overhang' '0.31'
set_param $vehicle_info_file '.["/**"].ros__parameters.rear_overhang' '0.35'
set_param $vehicle_info_file '.["/**"].ros__parameters.vehicle_height' '1.686'

if [ $# -gt 0 ]; then
  exec "$@"
fi

sleep infinity
