#!/bin/bash

set -e
cd ~/glx-docker-headless-gpu
docker build -t justx --no-cache .
cd turbovnc
# install latest aws tools
sudo yum install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 921287185969.dkr.ecr.us-east-1.amazonaws.com
sed -i 's/FROM paulruvolo\/testneato/FROM justx/g' Dockerfile
sed -i 's/# COPY --from=/COPY --from=/g' Dockerfile
docker build -t qeasim --no-cache .

cd nogpu
sed -i 's/FROM qeasimnvidia435/FROM qeasim/g' Dockerfile
docker build -t qeasimnogpu --no-cache .

docker tag justx 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:latest
docker tag qeasim 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasim
docker tag qeasimnogpu 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasimnogpu
docker push 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:latest
docker push 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasim
docker push 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasimnogpu


