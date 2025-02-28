#!/bin/bash
# provision-haproxy.sh: Instala y configura HAProxy en la VM haproxy.

# Actualizar el sistema
sudo apt-get update -y

# Instalar HAProxy
sudo apt-get install -y haproxy

# Configurar HAProxy
# Se copia un archivo de configuración personalizado a /etc/haproxy/haproxy.cfg
cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
global
    log /dev/log    local0
    maxconn 4096
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend http-in
    bind *:80
    default_backend web_servers
    # Configurar página de error personalizada
    errorfile 503 /etc/haproxy/errors/503.http

backend web_servers
    balance roundrobin
    option httpchk GET /health
    server web1 192.168.100.3:3000 check
    server web2 192.168.100.4:3001 check
EOF

# Crear la carpeta para errores y archivo 503 personalizado
sudo mkdir -p /etc/haproxy/errors
cat <<EOF | sudo tee /etc/haproxy/errors/503.http
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html>
  <head><title>Servicio No Disponible</title></head>
  <body>
    <h1>Lo sentimos, el servicio no está disponible en este momento.</h1>
  </body>
</html>
EOF

# Reiniciar HAProxy para aplicar los cambios
sudo systemctl restart haproxy
