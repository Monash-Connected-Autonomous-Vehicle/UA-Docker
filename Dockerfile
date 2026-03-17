# Base image: ROS 2 Humble on Ubuntu 22.04
FROM ros:humble-ros-core

# Install dev tools and dependencies, including tmux
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  python3-pip \
  python3-colcon-common-extensions \
  build-essential \
  python3-rosdep \
  git \
  wget \
  curl \
  nano \
  vim \
  iputils-ping \
  tmux \
  neovim \
  openssh-client \
  ros-humble-rviz2 \
  ros-humble-rqt-graph \
  ros-humble-turtlesim \
  sudo \
  unzip \
  dbus-x11 \
  openbox \
  xterm \
  x11-xserver-utils \
  mesa-utils \
  libgl1-mesa-dri \
  tigervnc-standalone-server \
  tigervnc-common \
  tigervnc-tools \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Setup non-root user
ARG USERNAME=mcav
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && usermod --shell /bin/bash $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# ROS 2 Environment setup
ENV ROS_DISTRO=humble
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc

# Add basic tmux.conf with bash as default shell
RUN echo "set-option -g default-shell /bin/bash" > /home/$USERNAME/.tmux.conf \
  && chown $USERNAME:$USERNAME /home/$USERNAME/.tmux.conf

# Set up workspace structure
ENV WORKSPACE_DIR=/home/$USERNAME/ros2_ws
WORKDIR $WORKSPACE_DIR
RUN mkdir -p src


# Initialize and run rosdep
WORKDIR $WORKSPACE_DIR
RUN rosdep init && rosdep update \
  && apt-get update \
  && rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO \
  && apt-get clean

# Change ownership to non-root user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Add ssh keys - before running the container make sure to run (in the same shell):
# 1. `eval "$(ssh-agent -s)"`
# 2. `ssh-add ~/.ssh/<ssh_private_key>`
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# noVNC (web-based VNC client) + websockify
RUN pip3 install --no-cache-dir \
  git+https://github.com/novnc/websockify.git@v0.10.0 \
  && git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc \
  && ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html

# Switch to non-root user
USER $USERNAME

# Final working dir
WORKDIR $WORKSPACE_DIR

# Optional VNC/noVNC desktop (opt-in at runtime)
ENV ENABLE_VNC=false
ENV VNC_RESOLUTION=1920x1080

USER root
COPY start_vnc.sh /start_vnc.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /start_vnc.sh /docker-entrypoint.sh \
  && chown $USERNAME:$USERNAME /start_vnc.sh /docker-entrypoint.sh
USER $USERNAME

EXPOSE 5901 6080

# Start interactive shell
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
