# Base oficial de Node 18 Alpine
FROM node:18-alpine

# Variables de entorno opcionales
ENV HOME=/home/jenkins

# Instalar paquetes necesarios
RUN apk add --no-cache bash git wget curl bash \
    && npm install -g mbt \
    && wget -q -O /usr/local/bin/piper https://github.com/SAP/jenkins-library/releases/latest/download/piper \
    && chmod +x /usr/local/bin/piper

# Crear usuario jenkins
RUN adduser -D jenkins
USER jenkins
WORKDIR /home/jenkins

