#!/bin/bash
cd /app
./API/API &
sudo http-server wwwroot/ -p 8080