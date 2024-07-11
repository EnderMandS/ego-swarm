FROM ros:noetic-ros-base-focal

ENV DEBIAN_FRONTEND noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m
ARG PROJECT_NAME=ego-swarm

# install binary
RUN apt update && \
    apt install -y vim tree wget curl git unzip ninja-build && \
    apt install -y zsh && \
    apt install -y libeigen3-dev && \
    apt install -y ros-${ROS_DISTRO}-cv-bridge && \
    DEBIAN_FRONTEND=noninteractive apt install -y keyboard-configuration && \
    apt install -y libarmadillo-dev && \
    apt install -y ros-${ROS_DISTRO}-pcl-conversions ros-${ROS_DISTRO}-pcl-ros ros-${ROS_DISTRO}-pcl-msgs && \
    apt install -y ros-${ROS_DISTRO}-tf ros-${ROS_DISTRO}-tf2 ros-${ROS_DISTRO}-laser-geometry && \
    apt install -y ros-${ROS_DISTRO}-rviz ros-${ROS_DISTRO}-roslint && \
    rm -rf /var/lib/apt/lists/*

# setup user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

# install zsh & set zsh as the default shell
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' /home/$USERNAME/.zshrc
SHELL ["/bin/zsh", "-c"]

# compile project
WORKDIR /home/$USERNAME/code
RUN git clone --depth 1 --recursive https://github.com/EnderMandS/ego-swarm.git ros_ws && cd ros_ws && \
    chmod 777 -R /home/$USERNAME/code && . /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_make -DCATKIN_WHITELIST_PACKAGES="" -DCMAKE_BUILD_TYPE=Release && \
    echo "source /home/m/code/ros_ws/devel/setup.zsh" >> /home/${USERNAME}/.zshrc

WORKDIR /home/$USERNAME/code/ros_ws

ENTRYPOINT [ "/bin/zsh" ]
