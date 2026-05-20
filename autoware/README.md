# UA Autoware Docker container
Refer to main README for proper guide to Docker. Contains ROS2 as well.

## Building the Docker image
First-time only or after updating docker image:
```bash
docker build -t ua-autoware-devel .
```

## Running the Docker container
### For software-only testing
Headless:
```bash
docker run -u root -it --net=host ua-autoware-devel
```

With display on http://localhost:6080/:
```bash
docker run -d -u root -it \
  -p 127.0.0.1:6080:6080 \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  ua-autoware-devel
```
When `ENABLE_VNC=true`, you must provide `VNC_PASSWORD` (avoid placeholder/default values). **NOTE**: VNC option is not intended for deployment.

**NOTE**: On some Windows machines, you might need to use the following to access via web browser, **however, this may expose your VNC server to the entire LAN**.
```bash
docker run -u root -it \
  -p 6080:6080 \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  ua-autoware-devel
```
### For software testing and vehicle control
If you intend to control the vehicle via CANbus and/or receive Velodyne LiDAR data:

```bash
sudo docker run -u root -it \
  --network host \
  --cap-add NET_RAW \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  -e NOVNC_PORT=16080 \
  ua-autoware-devel
```

Open the noVNC web UI at `http://localhost:16080/`.

**NOTE**: `-p` port-mapping flags are silently ignored by Docker when `--network host` is used — the container shares the host's network stack directly, so `vncserver` and `novnc_proxy` bind to host ports themselves. `NOVNC_PORT=16080` is used here instead of the default `6080` because `6080` is commonly taken by other dev tooling. If port `5901` (VNC display `:1`) is also taken on your host, override `VNC_DISPLAY` (e.g. `-e VNC_DISPLAY=:10` to use port 5910) and remember to use the matching `export DISPLAY=:10` inside the container.

### Main Dockerfile Arguments
- `ENABLE_VNC`: Whether to activate VNC for connecting to display, defaults to `false`.
- `VNC_PASSWORD`: Required when `ENABLE_VNC=true`; used to protect VNC access.
- `VNC_DISPLAY`: X display to use for the VNC server, defaults to `:1` (port 5901). Override when port 5901 is already in use on the host (only relevant under `--network host`). Must match the form `:N` where N is a non-negative integer.
- `NOVNC_PORT`: Port the noVNC web proxy listens on, defaults to `6080`. Override when port 6080 is already in use on the host (only relevant under `--network host`).

## Demonstrations
### Launching Planning Simulator without vehicle control
A common test is to run the planning simulator (as non-root user). Navigate to `autoware.twizy` and run:
```bash
source install/setup.bash

export DISPLAY=:1

ros2 launch autoware_launch planning_simulator.launch.xml \
map_path:=/home/mcav/autoware_map/Monash_Clayton_campus_simulation_only \
rviz:="$ENABLE_VNC"
```

### Launching Planning Simulator with vehicle control
Ensure CAN connection is setup and working (see Notion). Then, navigate to `autoware.twizy` and run:
```bash
source install/setup.bash

export DISPLAY=:1

ros2 launch autoware_launch planning_simulator.launch.xml \
vehicle_simulation:=false \
map_path:=/home/mcav/autoware_map/Monash_Clayton_campus_simulation_only \
rviz:="$ENABLE_VNC"
```

