#!/bin/bash

#docker build -t jenkins-agent:ubuntu .
docker build -t jenkins-agent:ubuntu --build-arg JENKINS_AGENT_SSH_PUBKEY="$(cat /var/lib/docker/volumes/jenkins_home/_data/.ssh/id_rsa.pub)" .
# -f Dockerfile.agent .

