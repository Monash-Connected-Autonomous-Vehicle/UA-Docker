# 🐋 mcav-docker

Docker enables running applications across different Operation Systems. At MCAV, it is a lightweight alterative to a full-scale Ubuntu 22 Virtual Machine.

**Please read it the entire README before starting to work with docker**

**Avoid comands to publish data, e.g. `docker push/commit ..`**


## Usage
1. Install docker CLI (once only): https://www.docker.com/get-started/  
  a. `docker --version` should work in the terminal after installation 
2. Clone this repository, navigate to the repository root then run `docker build -t ros2-vehicle-interface .` (this command can take ~5 mins to run during the first time, other times are quicker due to caching)
3. Run the docker image:
```bash
docker run -d --name ros2-vehicle-interface -e ENABLE_VNC=true \
  -p 127.0.0.1:5901:5901 -p 127.0.0.1:6080:6080 \
  ros2-vehicle-interface sleep infinity
```

## Accessing Container
2 options:
- Attach (i.e. open terminal connected) to docker via terminal as needed: `docker exec -it ros2-vehicle-interface bash`
- Or, go to http://localhost:6080/ and use password=`password` to login. This opens an blank background usually containing a single terminal. Right click to open terminal more terminals, and you run apps like `rviz2` or Autware Planning simulations, as you would with a regular Ubuntu VM.

## Useful Commands
Assume all these commands are ran in **Host machine**, unless otherwise specified.
- Stop container: `docker stop <container_name>`
- Start stopped container: `docker start  <container_name>`
  - You can add `-ai` to attach at the same time
- Attach to running container: `docker exec -it ros2-vehicle-interface bash`
- List containers: `docker ps`, use `-a` option to include stopped containers
- (Inside container) Exit from container: `exit`
- Attach to an active container: `docker exec -it <container_name> bash`
- Remove container: `docker rm -f <container_name>`
- List images: `docker images`
- [tmux](https://github.com/tmux/tmux/wiki): `tmux`, not a docker comand but a useful tool to manage multiple windows

## `git commit`-ing inside a Docker container
If you plan to commit code or work with private repos **you do not need to create an SSH key just for docker** (assuming you already have an SSH key on your **host machine** and working in an Unix/Unix-like terminal, i.e. MacOS or Windows WSL).

There are different instructions on how to set this up depending on your operating systems and container applications. In general, all of them require running this before the `docker run` command:  
On **host machine's** terminal if using `id_ed25519` ssh key:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l
ssh -T git@github.com
```
... or, if using `id_rsa`:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
ssh-add -l
ssh -T git@github.com
```

Then you'll need to modify the `docker run` to perform "SSH-Agent forwarding". You're encouraged to find the correct modification for your system. It should look similar to this (MacOS example with OrbStack):

```bash
docker run -d --name ros2-vehicle-interface -e ENABLE_VNC=true \
  -v /run/host-services/ssh-auth.sock:/agent.sock \
  -e SSH_AUTH_SOCK=/agent.sock \
  -p 127.0.0.1:5901:5901 -p 127.0.0.1:6080:6080 \
  ros2-vehicle-interface sleep infinity
```

Then you must attach as root:
`docker exec -u root -it ros2-vehicle-interface bash` before `git commit`-ing

You can verify if this is successful with `ssh -T git@github.com` **in the container**.


## UA-Specific Setup
Here's setup commands to create a minimal ros2 workspace containing [SD-VehicleInterface](https://github.com/Monash-Connected-Autonomous-Vehicle/SD-VehicleInterface), [autoware-dummy-publisher](https://github.com/Monash-Connected-Autonomous-Vehicle/autoware-dummy-publisher/tree/main/py_publishautowaremsgs) and other dependencies. If you're considering runnning Autoware, refer to this [repo](https://github.com/Monash-Connected-Autonomous-Vehicle/grpc-autoware-planning-interface).

```bash
cd /home/mcav/ros2_ws/src/
git clone https://github.com/Monash-Connected-Autonomous-Vehicle/SD-VehicleInterface.git
git clone https://github.com/autowarefoundation/autoware_msgs.git
git clone https://github.com/Monash-Connected-Autonomous-Vehicle/autoware-dummy-publisher.git
cd ..
source /opt/ros/humble/setup.bash
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

Quick testing  
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