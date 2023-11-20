FROM nvidia/cuda:11.5.2-devel-ubuntu20.04

# set time zone and disable interactive mode 
# so the user does not need to answer interactive questions during installation of some packages
ENV TZ="Europe/Amsterdam"
ENV DEBIAN_FRONTEND=noninteractive

# install dependencies of ElasticFusion
RUN apt update
RUN apt install -y cmake git \
  build-essential libusb-1.0-0-dev libudev-dev \
  openjdk-11-jdk freeglut3-dev libglew-dev \
  libsuitesparse-dev zlib1g-dev libjpeg-dev

# install python pip to install the latest version of cmake
RUN apt install -y python3 python3-pip
RUN pip3 install cmake

# enable debuggig if problems encountered
RUN apt install -y gdb

# IMPORTANT: enable compute and graphics, etc
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

# create a non-root user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
WORKDIR /home/$USERNAME

# Uncomment to add vnc support
#RUN apt install -y x11vnc xvfb
#RUN echo "exec /bin/bash" > ~/.xinitrc && chmod +x ~/.xinitrc
#CMD ["v11vnc", "-create", "-forever"]

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]