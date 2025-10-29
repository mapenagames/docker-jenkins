
#una vez configurado el nodo en jenkins ejecutar la sig.linea para que corra el servicio y quede levantado el nodo


#curl -sO http://172.17.0.2:8080/jnlpJars/agent.jar
#java -jar agent.jar -url http://localhost:8080/ -secret 19ab8d9c6fb8b8370a3bb01effc990988f8b36ed5e981e2adf92051c71cf8fb0 -name "jenkins-agent" -webSocket -workDir "/home/jenkins"
#


#!/bin/bash
set -e

# Variables
AGENT_CONTAINER="jenkins-agent"
JENKINS_HOST="jenkins"       # nombre del contenedor Jenkins dentro de la red
JENKINS_PORT=8080
AGENT_NAME="jenkins-agent"
AGENT_WORKDIR="/home/jenkins"
SECRET="19ab8d9c6fb8b8370a3bb01effc990988f8b36ed5e981e2adf92051c71cf8fb0"

echo "🚀 Iniciando agente JNLP/WebSocket persistente en $AGENT_CONTAINER..."

docker exec -d $AGENT_CONTAINER bash -c "
  cd $AGENT_WORKDIR
  # Descargar agent.jar si no existe
  if [ ! -f agent.jar ]; then
    echo '⬇️ Descargando agent.jar desde Jenkins...'
    curl -sO http://$JENKINS_HOST:$JENKINS_PORT/jnlpJars/agent.jar
  fi
  echo '☕ Iniciando agente en segundo plano...'
  nohup java -jar agent.jar \
    -url http://$JENKINS_HOST:$JENKINS_PORT/ \
    -secret $SECRET \
    -name \"$AGENT_NAME\" \
    -workDir $AGENT_WORKDIR \
    -webSocket \
    > $AGENT_WORKDIR/agent.log 2>&1 &
"

echo "✅ Agente iniciado en background. Logs en $AGENT_WORKDIR/agent.log dentro del contenedor."
echo "Para ver los logs: docker exec -it $AGENT_CONTAINER tail -f $AGENT_WORKDIR/agent.log"

