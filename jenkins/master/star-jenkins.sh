#!/bin/bash
# ==========================================
# Script para iniciar Jenkins en Docker
# Autor: (tu nombre)
# ==========================================

CONTAINER_NAME="jenkins"
IMAGE_NAME="jenkins/jenkins:lts"
PORT_WEB=8080
PORT_AGENT=50000
VOLUME_NAME="jenkins_home"

# Verificar si Docker está corriendo
if ! systemctl is-active --quiet docker; then
    echo "🔹 Iniciando servicio Docker..."
    sudo systemctl start docker
fi

# Verificar si el contenedor ya existe
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "✅ Jenkins ya está corriendo en http://localhost:$PORT_WEB"
    else
        echo "🔹 Iniciando contenedor Jenkins existente..."
        docker start $CONTAINER_NAME
        echo "✅ Jenkins iniciado en http://localhost:$PORT_WEB"
    fi
else
    echo "🔹 Descargando imagen Jenkins (si no existe)..."
    docker pull $IMAGE_NAME

    echo "🔹 Creando nuevo contenedor Jenkins..."
    docker run -d \
      --name $CONTAINER_NAME \
      -p $PORT_WEB:8080 \
      -p $PORT_AGENT:50000 \
      -v $VOLUME_NAME:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      $IMAGE_NAME

    echo "✅ Jenkins iniciado en http://localhost:$PORT_WEB"
    echo "🔑 Para obtener la contraseña inicial:"
    echo "   docker exec -it $CONTAINER_NAME cat /var/jenkins_home/secrets/initialAdminPassword"
fi

