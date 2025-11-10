# Dockerfile
FROM sonatype/nexus3:latest

# Opcional: Copiar configuración personalizada
# COPY nexus.properties /opt/sonatype/nexus/etc/nexus.properties
# COPY realm.properties /opt/sonatype/nexus/etc/realm.properties

# Exponer puertos
EXPOSE 8081 8082 8083

# Volumen persistente
VOLUME /nexus-data

# Etiqueta para identificar tu imagen
LABEL maintainer="tu-email@dominio.com"
LABEL version="1.0"
