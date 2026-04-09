FROM ros:humble-ros-core@sha256:e0409a258a7a1275fe8b9afc6ce7ff1e75e9b5ba73b51b6d06fb16b2726f95e2

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    unzip \
    ripgrep \
    tmux \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    python3-colcon-common-extensions \
    build-essential \
    python3-rosdep \
    nano \
    vim \
    iputils-ping \
    tmux \
    neovim \
    openssh-client \
    ros-humble-rviz2 \
    ros-humble-rqt-graph \
    ros-humble-turtlesim \
    dbus-x11 \
    openbox \
    xterm \
    x11-xserver-utils \
    mesa-utils \
    libgl1-mesa-dri \
    websockify \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && pip3 install --no-cache-dir --upgrade \
    "cryptography>=44.0.0,<47.0.0"

# Setup non-root user
ARG USERNAME=mcav
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod --shell /bin/bash $USERNAME

# ROS 2 Environment setup
ENV ROS_DISTRO=humble
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc

# Add basic tmux.conf with bash as default shell
RUN echo "set-option -g default-shell /bin/bash" > /home/$USERNAME/.tmux.conf \
    && chown $USERNAME:$USERNAME /home/$USERNAME/.tmux.conf

# Change ownership to non-root user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME && \
    mkdir -p /home/$USERNAME/.ssh && \
    chmod 700 /home/$USERNAME/.ssh && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

ENV NOVNC_COMMIT=8e1ebdffba02e651c399dacef841f8941f6ad6e4

RUN git clone https://github.com/novnc/noVNC.git /usr/lib/novnc && \
    cd /usr/lib/novnc && \
    git fetch origin ${NOVNC_COMMIT} && \
    git checkout ${NOVNC_COMMIT} && \
    git reset --hard ${NOVNC_COMMIT} && \
    ln -s vnc.html index.html

# Switch to non-root user
USER $USERNAME

# Optional VNC/noVNC desktop (opt-in at runtime)
ENV ENABLE_VNC=false
ENV VNC_RESOLUTION=1920x1080

USER root
COPY start_vnc.sh /start_vnc.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /start_vnc.sh /entrypoint.sh \
    && chown $USERNAME:$USERNAME /start_vnc.sh /entrypoint.sh
USER $USERNAME

# Start interactive shell
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
