from nvidia/cuda:11.5.2-devel-ubuntu20.04

ENV TZ="Europe/Amsterdam"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y cmake git \
  build-essential libusb-1.0-0-dev libudev-dev \
  openjdk-11-jdk freeglut3-dev libglew-dev \
  libsuitesparse-dev zlib1g-dev libjpeg-dev

RUN apt install -y python3 python3-pip

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

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
WORKDIR /home/$USERNAME
RUN pip3 install cmake

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]