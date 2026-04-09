# UA Autoware Docker container
Refer to main README for proper guide to Docker. Contains ROS2 as well.

## Simple setup
Build Docker Image:
```bash
docker build -t ua-autoware-devel .
```

Run container:
- Headless: 
```bash
docker run -u root -it --net=host ua-autoware-devel
```

- With display on http://localhost:6080/ :
```bash
docker run -u root -it \
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

### Main Dockerfile Arguments
- `ENABLE_VNC`: Whether to activate VNC for connecting to display, defaults to `false`.
- `VNC_PASSWORD`: Required when `ENABLE_VNC=true`; used to protect VNC access.

### Launching Planning Sim
A common test is to run the planning simulator:
```bash
source /opt/autoware/setup.bash

export DISPLAY=:1.0

ros2 launch autoware_launch planning_simulator.launch.xml \
map_path:="/root/autoware_map/Monash_Clayton_campus_simulation_only" \
vehicle_model:=sample_vehicle \
sensor_model:=sample_sensor_kit \
rviz:="$ENABLE_VNC"
```
