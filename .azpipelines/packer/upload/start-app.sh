#!/usr/bin/env bash

# Start API
cd /app
./API/API &

# Start Angular client
sudo http-server wwwroot/ -p 8080