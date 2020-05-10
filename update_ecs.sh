#!/bin/bash

set -e
cd ~/glx-docker-headless-gpu
docker build -t justx .
cd turbovnc
sed -i 's/FROM paulruvolo\/testneato/FROM justx/g' Dockerfile
sed -i 's/# COPY --from=/COPY --from=/g' Dockerfile
docker build -t qeasim .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 921287185969.dkr.ecr.us-east-1.amazonaws.com
docker tag justx 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:latest
docker tag qeasim 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasim
docker push 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:latest
docker push 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasim


