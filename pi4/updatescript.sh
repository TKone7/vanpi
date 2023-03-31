#!/bin/bash

# define variables
Server='https://git.pekaway.de/Vincent/vanpi/-/raw/main/pi4/'
Version='v1.1.0'

# remove packages.txt and package.json if they already exist
cd ~/pekaway
rm -f packages.txt
rm -f package.json

# download new files packages.txt and package.json
wget ${Server}packages.txt
wget ${Server}package.json

# make a backup of the existing package.json and replace it with the new file
cp ~/.node-red/package.json ~/pekaway/nrbackups/package-backup.json
cp ~/pekaway/package.json ~/.node-red/package.json

# install packages and dependencies
sudo apt install $(cat ~/pekaway/packages.txt) -y
cd ~/.node-red
npm install

# remove downloaded files
rm -f ~/pekaway/packages.txt && rm -f ~/pekaway/package.json

# backup Node-RED flows
cp ~/.node-red/flows_pekaway.json '~/pekaway/nrbackups/flows_pekaway_`date +%d-%m-%Y_%I:%M:%S%p`.json'

# replace version number
echo ${Version} >| ~/pekaway/version

# set update = true to show up when opening dashboard
echo "1" >| ~/pekaway/update

# download new flows and replace the old file
curl ${Server}flows.json > ~/pekaway/pkwUpdate/flows_pekaway.json 
cp ~/pekaway/pkwUpdate/flows_pekaway.json ~/.node-red/flows_pekaway.json
sudo systemctl restart nodered.service
rm ~/pekaway/pkwUpdate/flows_pekaway.json
