#!/bin/bash
# provision-web.sh: Aprovisiona la VM para que corra el servicio web y un agente Consul.
PORT=$1
IP=$(hostname -I | awk '{print $1}')

# Actualizar el sistema
sudo apt-get update -y

# Instalar NodeJS y npm
sudo apt-get install -y nodejs npm git

# Instalar Consul
wget -O consul.zip https://releases.hashicorp.com/consul/1.13.2/consul_1.13.2_linux_amd64.zip
sudo apt-get install -y unzip
unzip consul.zip
sudo mv consul /usr/local/bin/
rm consul.zip

# Iniciar Consul agent en modo dev
nohup consul agent -dev -bind=$IP -client=0.0.0.0 -data-dir=/tmp/consul > consul.log 2>&1 &

# Clonar el repositorio con la aplicación (si aún no existe)
if [ ! -d "consulService" ]; then
  git clone https://github.com/omondragon/consulService.git
fi

cd consulService/app

# Instalar dependencias de la aplicación
npm install

# Iniciar la aplicación en el puerto indicado, la aplicación se registra en Consul automáticamente
nohup node index.js $PORT > app.log 2>&1 &
