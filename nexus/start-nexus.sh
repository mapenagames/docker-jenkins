#!/bin/bash
# start-nexus.sh

set -e  # Detiene si hay error

IMAGE_NAME="custom-nexus3"
CONTAINER_NAME="nexus-oss"
DATA_DIR="./nexus-data"
HOST_PORT=8081
DOCKER_PORT=8081

echo "Construyendo imagen personalizada: $IMAGE_NAME..."
docker build -t $IMAGE_NAME .

echo "Creando directorio de datos persistentes: $DATA_DIR"
mkdir -p $DATA_DIR

echo "Deteniendo contenedor anterior si existe..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

echo "Iniciando Nexus OSS..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $HOST_PORT:$DOCKER_PORT \
  -p 8082:8082 \
  -p 8083:8083 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v nexus-data:/nexus-data \
  --restart unless-stopped \
  $IMAGE_NAME

echo "Nexus iniciado. Esperando a que arranque..."

# Esperar a que el servicio responda
until curl -s http://localhost:$HOST_PORT > /dev/null 2>&1; do
  printf "."
  sleep 3
done

echo ""
echo "Nexus OSS está listo!"
echo "   UI: http://localhost:$HOST_PORT"
echo "   Docker Registry (opcional): http://localhost:8082"
echo ""
echo "Contraseña inicial de admin (primer arranque):"
echo "   $(docker exec $CONTAINER_NAME cat /nexus-data/admin.password)"
echo ""
echo "Accede y cambia la contraseña inmediatamente."
echo "Logs: docker logs -f $CONTAINER_NAME"
