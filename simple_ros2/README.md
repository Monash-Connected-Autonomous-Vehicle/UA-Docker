# Simple ROS2 Docker container
\+ VNC for optional browser access

## Simple setup
Build Docker Image: 
```bash
docker build -t ua-ros2 .
```

Run container:
- Headless: 
```bash
docker run -u root -it ua-ros2
```

- With display on http://localhost:6080/ :
```bash
docker run -u root -it \
  -p 127.0.0.1:6080:6080 \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  ua-ros2
```
When `ENABLE_VNC=true`, you must provide `VNC_PASSWORD` (avoid placeholder/default values). **NOTE**: VNC option is not intended for deployment.

**NOTE**: On some Windows machines, you might need to use the following to access via web browser, **however, this may expose your VNC server to the entire LAN**.
```bash
docker run -u root -it \
  -p 6080:6080 \
  -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  ua-ros2
```

### Main Dockerfile Arguments
- `ENABLE_VNC`: Whether to activate VNC for connecting to display, defaults to `false`.
- `VNC_PASSWORD`: Required when `ENABLE_VNC=true`; used to protect VNC access.

## SD-VehicleInterface Workspace Setup
Here's setup commands to create a minimal ros2 workspace containing [SD-VehicleInterface](https://github.com/Monash-Connected-Autonomous-Vehicle/SD-VehicleInterface), [autoware-dummy-publisher](https://github.com/Monash-Connected-Autonomous-Vehicle/autoware-dummy-publisher/tree/main/py_publishautowaremsgs) and other dependencies. If you're considering runnning Autoware, go to the `autoware` directory of this repository.

```bash
mkdir -p ~/basic_ua_ctrl_ws/src/
cd ~/basic_ua_ctrl_ws/src/
git clone https://github.com/Monash-Connected-Autonomous-Vehicle/SD-VehicleInterface.git
git clone https://github.com/autowarefoundation/autoware_msgs.git
git clone https://github.com/Monash-Connected-Autonomous-Vehicle/autoware-dummy-publisher.git
cd ..
source /opt/ros/humble/setup.bash
sudo apt update && sudo apt upgrade
sudo rosdep init
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

Quick testing commands in `~/basic_ua_ctrl_ws/src/`  
Terminal 1/tmux window 1
```bash
source install/setup.bash
ros2 launch sd_vehicle_interface sd_vehicle_interface.launch.xml sd_simulation_mode:=true
```

Terminal 2/tmux window 2
```bash
source install/setup.bash
ros2 run py_publishautowaremsgs controller
```

Terminal 3/tmux window 3
```bash
source install/setup.bash
ros2 topic echo <topic-you-are-controlling>
```
