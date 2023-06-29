#!/bin/bash -e
sudo apt-get install -y unzip
sudo mkdir /app

sudo unzip /tmp/API.zip -d /app/API
sudo unzip /tmp/cliente.zip -d /app/cliente
sudo cp /tmp/appsettings.json /app/API/appsettings.json

sudo chmod 777 /app/API/API

sudo cp /tmp/start-app.sh /app/start-app.sh
sudo chmod +x /app/start-app.sh
sudo cp /tmp/datingapp.service /lib/systemd/system/datingapp.service
sudo systemctl daemon-reload
sudo systemctl enable datingapp.service

echo "y" | sudo ufw enable
sudo ufw allow 22
sudo ufw allow 8080
sudo ufw allow 5000