# Build ElasticFusion in Docker

This repo shows how to build and run [ElasticFusion](https://github.com/mp3guy/ElasticFusion.git) in a docker container.
All the following instructions are based on Ubuntu OS but they could be easily ported to other Linux distributions.

![demo](img/Screenshot%20from%202023-11-20%2022-21-46.png)

This repo could also be used as an example to configure a docker container that is suitable for CUDA and OpenGL development.
For example, when troubleshooting the container, I used VS Code to remotely debug ElasticFusion.
The advantage is that we don't need to install cuda toolkit in the host OS so it won't pollute the host OS.
And we could pull images of various versions of cuda.

## Install and configure docker

Install `docker`:

``` sh
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
```

Install `nvidia-container-toolkit`:

``` sh
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && \
    sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

Configure docker to support nvidia devices:

``` cpp
sudo nvidia-ctk runtime configure --runtime=docker
#Restart the Docker daemon:
sudo systemctl restart docker
sudo nvidia-ctk runtime configure --runtime=containerd
```

## Get Elastic Fusion

``` sh
git clone https://github.com/mp3guy/ElasticFusion.git
cd ElasticFusion/
git submodule update --init
```

## Build Elastic Fusion

Build the image of the docker file:

``` sh
docker buildx build -t nvidia11 .
```

Manually start the container with the repo mapped:

``` sh
docker container run -it --rm --gpus all \
  -v ./ElasticFusion:/home/user/ElasticFusion \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --network=host \
  -e DISPLAY=${DISPLAY} nvidia11 bash
```

Build the repo in the container:

``` sh
cd ElasticFusion/third-party/OpenNI2/
make -j8
cd ../Pangolin/
mkdir build
cd build
cmake .. -DEIGEN_INCLUDE_DIR=$HOME/ElasticFusion/third-party/Eigen/ -DBUILD_PANGOLIN_PYTHON=false
make -j8
cd ../../..
mkdir build
cd build/
cmake ..
make  -j8
```

Testing:

``` sh
./ElasticFusion -l ../dyson_lab.klg
```

## Use docker compose

When the project is built, we could use `docker-compose` to simplify the startup command:

``` sh
docker compose build
docker compose up
```
