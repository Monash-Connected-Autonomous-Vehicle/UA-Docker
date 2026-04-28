# UA-Docker

Docker enables running applications across different Operation Systems. At MCAV, it is a lightweight alterative to a full-scale Ubuntu 22 Virtual Machine.

**Please read the entire README before starting to work with docker**

**Avoid commands that publish data (e.g. `docker push/commit ..`)**

## Structure
Each directory contains a `Dockerfile` for a unique purpose. View nested READMEs for more info. Tips that apply to any docker container can be found below. All `Dockerfile` provides the option for running a VNC server, which enables us to use GUI apps via a browser.

Modifying the `Dockerfile`? Ensure you rebuild before running the container.

## Usage
1. Install docker CLI (once only): https://www.docker.com/get-started/  
    a. `docker --version` should work in the terminal after installation 
2. Clone this repository
3. Open the terminal at the repository root and navigate to the directory that has the `Dockerfile` your you want (e.g. `cd autoware`, `cd basic_ros2`)
4. Build the image with `docker build -t <custom-name> .` (e.g. `docker build -t my-ua-image .`)
5. Run the docker image and use args specified by the nested README (e.g. `docker run <custom-name> ...`)


## Useful Commands
Assume all these commands are ran in **Host machine**, unless otherwise specified.
The most useful option `--help` to get info about command (e.g. `docker run --help`)

Format of useful commands:
```txt
- main command (e.g. `docker <command>`)
    - <option> to do something (e.g. `docker <command> <option>`)
```

Useful commands:

- Run container from image: `docker run -u root <image-name-or-id>`
    - `-d` to run in the background
    - `-it` to run with a terminal connected to container
    - `--rm` to remove container immediately after you exit
    - `--name` to give your new container a name
    - `-u root` for root privileges
- Stop container: `docker stop <container_name>`
- Start stopped container: `docker start <container_name>`
  - `-ai` to attach at the same time
- Attach to running container: `docker exec -u root -it <container_name> bash`
- List containers: `docker ps`
    - `-a` option to include stopped containers
- (Inside container) Exit from container: `exit`
- Attach to an active container: `docker exec -u root -it <container_name> bash`
    - `-u root` for root privileges
- Remove container: `docker rm <container_name>`
    - `-f` to remove forcefully
- List images: `docker images`
- Remove dangling images: `docker image prune`
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
docker run -u root -d --name ros2-vehicle-interface -e ENABLE_VNC=true \
  -e VNC_PASSWORD="${VNC_PASSWORD:?Set VNC_PASSWORD first}" \
  -v /run/host-services/ssh-auth.sock:/agent.sock \
  -e SSH_AUTH_SOCK=/agent.sock \
  -p 127.0.0.1:6080:6080 \
  ros2-vehicle-interface sleep infinity
```
Then attach:
`docker exec -u root -it ros2-vehicle-interface bash`

You can verify if this is successful with `ssh -T git@github.com` **in the container**.

## Accessing Container
2 options:
- Attach (i.e. open terminal connected) to docker via terminal as needed: `docker exec -u root -it <container-name> bash`
- Or, if you enabled VNC in `docker run`, go to http://localhost:6080/ and login with the `VNC_PASSWORD` you set. This opens a simple desktop. Right click to open more terminals, and run apps like `rviz2` or Autoware planning simulations (if using an Autoware container), as you would with a regular Ubuntu VM.
