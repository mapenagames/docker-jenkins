#!/bin/bash
set -e

echo "🚀 Iniciando entorno Jenkins + agente..."

# Variables
NETWORK_NAME="jenkins-net"
JENKINS_CONTAINER="jenkins"
AGENT_CONTAINER="jenkins-agent"
AGENT_IMAGE="jenkins-agent:ubuntu"
DOCKERFILE_AGENT="Dockerfile.agent"

# 1️⃣ Crear red Docker
if ! docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
  echo "🌐 Creando red Docker: $NETWORK_NAME"
  docker network create $NETWORK_NAME
else
  echo "🌐 Red $NETWORK_NAME ya existe."
fi

# 2️⃣ Levantar Jenkins
if ! docker ps --format '{{.Names}}' | grep -q "^$JENKINS_CONTAINER$"; then
  echo "🧱 Levantando contenedor Jenkins..."
  docker run -d \
    --name $JENKINS_CONTAINER \
    --network $NETWORK_NAME \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts

  echo "⏳ Esperando que Jenkins arranque..."
  sleep 10
else
  echo "🧱 Jenkins ya está corriendo."
fi

# 3️⃣ Generar clave SSH dentro del contenedor Jenkins
echo "🔐 Generando clave SSH dentro de Jenkins..."
docker exec $JENKINS_CONTAINER bash -c '
  mkdir -p /var/jenkins_home/.ssh
  if [ ! -f /var/jenkins_home/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "jenkins-master" -f /var/jenkins_home/.ssh/id_rsa -N ""
  fi
  chmod 600 /var/jenkins_home/.ssh/id_rsa
  chmod 644 /var/jenkins_home/.ssh/id_rsa.pub
'
PUBKEY=$(docker exec $JENKINS_CONTAINER cat /var/jenkins_home/.ssh/id_rsa.pub)

# 4️⃣ Construir imagen del agente
if [ ! -f "$DOCKERFILE_AGENT" ]; then
  echo "❌ No se encontró el archivo $DOCKERFILE_AGENT"
  exit 1
fi

echo "🧩 Construyendo imagen del agente ($AGENT_IMAGE)..."
docker build -t $AGENT_IMAGE \
  --build-arg JENKINS_AGENT_SSH_PUBKEY="$PUBKEY" \
  -f $DOCKERFILE_AGENT .

# 5️⃣ Levantar agente (con privilegios para Docker)
if docker ps --format '{{.Names}}' | grep -q "^$AGENT_CONTAINER$"; then
  echo "🧹 Eliminando agente anterior..."
  docker rm -f $AGENT_CONTAINER
fi

echo "🚀 Levantando agente Jenkins con acceso Docker..."
docker run -d \
  --name $AGENT_CONTAINER \
  --network $NETWORK_NAME \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_agent_home:/home/jenkins \  
  $AGENT_IMAGE
echo "fin paso docker run"

docker image prune -f

# 6️⃣ Test automático de Docker en el agente
echo "🔍 Verificando acceso al daemon Docker dentro del agente..."
docker exec $AGENT_CONTAINER bash -c '
  echo "👤 Usuario actual: $(whoami)"
  echo "📦 Contenedores activos dentro del agente:"
  docker ps
  echo "🧪 Probando ejecución de contenedor hijo..."
  docker run --rm alpine echo "✅ Docker funciona correctamente dentro del agente"
'

# 7️⃣ Probar conectividad SSH desde Jenkins al agente
echo "🔍 Probando conexión SSH desde Jenkins al agente..."
if docker exec $JENKINS_CONTAINER ssh -o StrictHostKeyChecking=no -i /var/jenkins_home/.ssh/id_rsa jenkins@$AGENT_CONTAINER hostname; then
  echo "✅ Conexión SSH exitosa."
else
  echo "⚠️ No se pudo conectar por SSH. Revisar logs."
  exit 1
fi

echo "✅ Jenkins y su agente están listos."
echo "👉 Accedé a Jenkins en: http://localhost:8080"
echo "   Contraseña inicial: docker exec $JENKINS_CONTAINER cat /var/jenkins_home/secrets/initialAdminPassword"
