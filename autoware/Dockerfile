FROM ghcr.io/autowarefoundation/autoware:universe-devel@sha256:d8e97a86bc628b686f299675442e7fc6aaf32cddb5115848af724eb56f4937a7 

ARG USERNAME=mcav
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG YQ_VERSION=v4.44.3
ARG YQ_SHA256=a2c097180dd884a8d50c956ee16a9cec070f30a7947cf4ebf87d5f36213e9ed7

RUN apt-get update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    unzip \
    ripgrep \
    tmux \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    openbox \
    xterm \
    x11-xserver-utils \
    dos2unix \
    supervisor \
    dbus-x11 \
    vim \
    bash-completion \
    tzdata \
    websockify \
    python3-pip \
    can-utils \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && pip3 install --no-cache-dir --upgrade \
    "cryptography>=44.0.0,<47.0.0"

RUN wget -qO /usr/local/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" && \
    echo "${YQ_SHA256}  /usr/local/bin/yq" | sha256sum -c - && \
    chmod +x /usr/local/bin/yq

ENV NOVNC_COMMIT=09440da5c1deccf579020292cfeeb8f7dc23f65b

RUN git clone https://github.com/novnc/noVNC.git /usr/lib/novnc && \
    cd /usr/lib/novnc && \
    git fetch origin ${NOVNC_COMMIT} && \
    git checkout ${NOVNC_COMMIT} && \
    git reset --hard ${NOVNC_COMMIT} && \
    ln -s vnc.html index.html

RUN groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" && \
    usermod --shell /bin/bash "${USERNAME}" && \
    mkdir -p "/home/${USERNAME}/.vnc" "/home/${USERNAME}/autoware_map" && \
    chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"

# Entry point updates these parameter files at startup.
RUN chown "${USERNAME}:${USERNAME}" \
    /opt/autoware/share/autoware_launch/config/planning/scenario_planning/common/common.param.yaml \
    /opt/autoware/share/sample_vehicle_description/config/vehicle_info.param.yaml

COPY entrypoint.sh /entrypoint.sh
COPY start_vnc.sh /start_vnc.sh
RUN chmod +x /entrypoint.sh /start_vnc.sh && \
    chown "${USERNAME}:${USERNAME}" /entrypoint.sh /start_vnc.sh

ENV ENABLE_VNC=false
ENV VNC_RESOLUTION=1920x1080
ENV HOME="/home/${USERNAME}"
ENV PATH="${PATH}:/home/${USERNAME}/.local/bin"
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV CMAKE_PREFIX_PATH="/opt/acados:${CMAKE_PREFIX_PATH}"
ENV ACADOS_SOURCE_DIR=/opt/acados
ENV LD_LIBRARY_PATH="/opt/acados/lib:${LD_LIBRARY_PATH}"

# Layer: clone + vcs import
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-vcstool \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/${USERNAME}
RUN git clone https://github.com/Monash-Connected-Autonomous-Vehicle/autoware.twizy.git -b feat/accommodate-for-docker

WORKDIR /home/${USERNAME}/autoware.twizy

# Import workspace dependencies
RUN /bin/bash -c "set -e && \
    mkdir -p src && \
    vcs import src < repositories/docker-no-nvidia-dep.autoware.repos"

# rosdep layer
RUN /bin/bash -c "set -e && \
    source /opt/autoware/setup.bash && \
    apt-get update && \
    rosdep update && \
    rosdep install -y \
        --from-paths src \
        --ignore-src \
        --rosdistro \$ROS_DISTRO && \
    rm -rf /var/lib/apt/lists/*"

# build layer
RUN /bin/bash -c "set -e && \
    source /opt/autoware/setup.bash && \
    colcon build --symlink-install \
        --cmake-args -DCMAKE_BUILD_TYPE=Release"

RUN chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/autoware.twizy"

USER ${USERNAME}
WORKDIR /home/${USERNAME}/autoware.twizy

ENTRYPOINT ["/entrypoint.sh"]
CMD []
