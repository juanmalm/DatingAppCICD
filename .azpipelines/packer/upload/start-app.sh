#!/bin/bash
cd /app
./API/API &
cd cliente
sudo http-server wwwroot/ -p 8080