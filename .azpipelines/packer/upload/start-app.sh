#!/bin/bash

# Start API
cd /app
./API/API &

# Start Angular client
cd cliente
sudo http-server wwwroot/ -p 8080