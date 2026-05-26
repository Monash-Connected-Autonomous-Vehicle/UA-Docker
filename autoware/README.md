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
docker run -u root -it ua-autoware-devel
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
You'll need to run the docker container on an Ubuntu VM with usb access to the PCAN-USB adapter.

```bash
sudo docker run -u root -it \
  --network host \
  --cap-add NET_ADMIN \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  -e VNC_DISPLAY=:42 \
  -e NOVNC_PORT=16080 \
  ua-autoware-devel
```

Then, inside the docker container, run: `sudo apt install -y linux-modules-extra-$(uname -r)`

Open the noVNC web UI at `http://localhost:16080/`.

**NOTE**: `-p` port-mapping flags are silently ignored by Docker when `--network host` is used — the container shares the host's network stack directly, so `vncserver` and `novnc_proxy` bind to host ports themselves. We override two ports to avoid the most common host-side collisions:
- `VNC_DISPLAY=:42` puts the VNC server on TCP port 5942 instead of the default 5901, which is often taken by host-side VNC tooling.
- `NOVNC_PORT=16080` puts the web UI on 16080 instead of the default 6080, which is commonly taken by other dev tooling.

Adjust both values freely if those ports are also in use on your host. The demo commands below pick up `VNC_DISPLAY` automatically, so they work for either networking mode without further edits.

### Main Dockerfile Arguments
- `ENABLE_VNC`: Whether to activate VNC for connecting to display, defaults to `false`.
- `VNC_PASSWORD`: Required when `ENABLE_VNC=true`; used to protect VNC access.
- `VNC_DISPLAY`: X display to use for the VNC server, defaults to `:1` (port 5901). Override under `--network host` if port 5901 is already in use on the host. Must match the form `:N` where N is a non-negative integer.
- `NOVNC_PORT`: Port the noVNC web proxy listens on, defaults to `6080`. Override under `--network host` if port 6080 is already in use on the host.

## Demonstrations
### Launching Planning Simulator without vehicle control
A common test is to run the planning simulator. Navigate to `autoware.twizy` and run:
```bash
source install/setup.bash

export DISPLAY="${VNC_DISPLAY:-:1}"

ros2 launch autoware_launch planning_simulator.launch.xml \
map_path:=/home/mcav/autoware_map/Monash_Clayton_campus_simulation_only \
rviz:="$ENABLE_VNC"
```

### Launching Planning Simulator with vehicle control
Ensure CAN connection is setup and working (see Notion). Then, navigate to `autoware.twizy` and run:
```bash
source install/setup.bash

export DISPLAY="${VNC_DISPLAY:-:1}"

ros2 launch autoware_launch planning_simulator.launch.xml \
vehicle_simulation:=false \
map_path:=/home/mcav/autoware_map/Monash_Clayton_campus_simulation_only \
rviz:="$ENABLE_VNC"
```

