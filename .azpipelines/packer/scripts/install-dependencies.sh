#!/bin/bash -e

# Install Node.js
echo "$(date +"%d-%b-%Y-%H-%M-%S") | Install NodeSource PPA..."
cd ~
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
echo "$(date +"%d-%b-%Y-%H-%M-%S") | apt-get install nodejs..."
sudo apt-get install nodejs -y
node -v
npm -v
echo "$(date +"%d-%b-%Y-%H-%M-%S") | apt-get install build-essential..."
sudo apt-get install build-essential -y

# Install http-server
sudo npm install http-server -g