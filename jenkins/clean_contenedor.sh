#!/bin/bash
set -e

echo "🧹 Limpiando todos los contenedores Docker..."
echo "============================================="

# 1️⃣ Detener todos los contenedores en ejecución
RUNNING_CONTAINERS=$(docker ps -q)
if [ -n "$RUNNING_CONTAINERS" ]; then
    echo "🛑 Deteniendo contenedores activos..."
    docker stop $RUNNING_CONTAINERS
else
    echo "✅ No hay contenedores activos."
fi

# 2️⃣ Eliminar todos los contenedores (detenidos o no)
ALL_CONTAINERS=$(docker ps -aq)
if [ -n "$ALL_CONTAINERS" ]; then
    echo "🧨 Eliminando todos los contenedores..."
    docker rm -f $ALL_CONTAINERS
else
    echo "✅ No hay contenedores para eliminar."
fi

# 3️⃣ Mostrar estado final
echo "============================================="
docker ps -a
echo "✅ Todos los contenedores fueron detenidos y eliminados."
