#!/bin/bash
# start-nexus.sh - Versión corregida para WSL2 + Docker Desktop

set -e

IMAGE_NAME="custom-nexus3"
CONTAINER_NAME="nexus-oss"
DATA_DIR="nexus-data"        # <-- Carpeta local en tu proyecto
HOST_PORT=8081
DOCKER_PORT=8081

export IMAGE_NAME
export CONTAINER_NAME
export DATA_DIR
export HOST_PORT
export DOCKER_PORT

docker build -t $IMAGE_NAME .

# echo "Creando directorio de datos persistentes: $DATA_DIR"
# mkdir -p $DATA_DIR

echo "Deteniendo contenedor anterior si existe..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

echo "Iniciando Nexus OSS..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $HOST_PORT:$DOCKER_PORT \
  -p 8082:8082 \
  -p 8083:8083 \
  -v $DATA_DIR:/nexus-data \
  --restart unless-stopped \
  $IMAGE_NAME


echo "Nexus iniciado. Esperando a que arranque..."

# Esperar a que responda
until curl -s http://localhost:$HOST_PORT > /dev/null 2>&1; do
  printf "."
  sleep 3
done

echo -e "\n"
echo "Nexus OSS está listo!"
echo "   UI: http://localhost:$HOST_PORT"
echo "   Docker Registry: http://localhost:8082"
echo ""
echo "Contraseña inicial de admin:"
echo "   $(docker exec $CONTAINER_NAME cat /nexus-data/admin.password 2>/dev/null || echo 'Aún no disponible')"
echo ""
echo "Accede YA y cambia la contraseña."
echo "Logs: docker logs -f $CONTAINER_NAME"
