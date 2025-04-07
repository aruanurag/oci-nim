#!/bin/bash

#Expand size
sudo /usr/libexec/oci-growfs -y

#Enable all the required repositories. To do this you are going to need the yum-utils package.
sudo dnf install -y dnf-utils zip unzip
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

#install Docker
sudo dnf remove -y runc
sudo dnf install -y docker-ce --nobest

#enable and start the docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service

#Install nvidia container toolkit
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo dnf install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker


export NGC_API_KEY=<Replace-with-your-api-key>
export LOCAL_NIM_CACHE=~/.cache/nim
mkdir -p "$LOCAL_NIM_CACHE"
echo "$NGC_API_KEY" | sudo docker login nvcr.io --username '$oauthtoken' --password-stdin
sudo docker run -d  --gpus all --restart=always  --shm-size=16GB  -e NGC_API_KEY=$NGC_API_KEY -v "$LOCAL_NIM_CACHE:/opt/nim/.cache"  -u $(id -u) -p 8000:8000     nvcr.io/nim/deepseek-ai/deepseek-r1-distill-llama-8b:1.5.2