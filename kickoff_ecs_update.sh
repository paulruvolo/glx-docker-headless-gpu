#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "USAGE: kickoff_ecs_update.sh aws_instance_host"
    exit 1
fi

ssh -i ~/Downloads/selfcontained.pem ec2-user@$1 sudo yum install -y git
scp -r -i ~/Downloads/selfcontained.pem ~/.aws ec2-user@$1:.
# ignore errors in git clone (e.g., directory already exists)
ssh -i ~/Downloads/selfcontained.pem ec2-user@$1 git clone https://github.com/paulruvolo/glx-docker-headless-gpu.git || true 
ssh -i ~/Downloads/selfcontained.pem ec2-user@$1 'cd ~/glx-docker-headless-gpu; ./update_ecs.sh'
