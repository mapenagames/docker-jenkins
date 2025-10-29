#!/bin/bash

#docker run -itd --name jenkins-agent -p 2222:22 -v /var/run/docker.sock:/var/run/docker.sock jenkins-agent:ubuntu bash

docker run -d  --name jenkins-agent -p 2222:22  -v /var/run/docker.sock:/var/run/docker.sock jenkins-agent:ubuntu

