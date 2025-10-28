docker network create jenkins-net

docker run -d \
  --name jenkins \
  --network jenkins-net \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

#entrar a jenkins
docker exec -it jenkins bash
ssh-keygen -t rsa -b 4096 -C "jenkins-master" -f /var/jenkins_home/.ssh/id_rsa -N ""
cat /var/jenkins_home/.ssh/id_rsa.pub

salir del contenedor jenkins (ctrl + q o exit)

# construir la imagen del agente.
docker build -t jenkins-agent:ubuntu \
  --build-arg JENKINS_AGENT_SSH_PUBKEY="$(docker exec jenkins cat /var/jenkins_home/.ssh/id_rsa.pub)" \
  -f dockerfile.agent .


#levantar el agente
docker run -d \
  --name jenkins-agent \
  --network jenkins-net \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-agent:ubuntu


# validar que los contenedores esta levantados
docker ps

#entro a jenkins y trato de conectarme al agente por medio de un ssh
docker exec -it jenkins bash
ssh -i /var/jenkins_home/.ssh/id_rsa jenkins@jenkins-agent



