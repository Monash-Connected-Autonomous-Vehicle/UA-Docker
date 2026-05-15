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
If you intend to control the vehicle via CANbus:

```bash
sudo docker run -u root -it \
  --network host \
  --cap-add NET_RAW \
  -p 127.0.0.1:6080:6080 \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  ua-autoware-devel
```

### Main Dockerfile Arguments
- `ENABLE_VNC`: Whether to activate VNC for connecting to display, defaults to `false`.
- `VNC_PASSWORD`: Required when `ENABLE_VNC=true`; used to protect VNC access.

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

