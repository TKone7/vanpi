#!/bin/bash

#define startdate
start=`date +%s`
startdate=`date`

# define server address
Server='https://git.pekaway.de/Vincent/vanpi/-/raw/main/pi4_bullseye/'

# define color variables
Cyan='\033[0;36m'
Red='\033[0;31m'
NC='\033[0m' #No Color

# get latest updates
echo -e "${Cyan}updating packages list${NC}"
sudo apt update
echo -e "${Cyan}upgrading packages${NC}"
sudo apt upgrade -y

# Enable I2C and 1-Wire
echo -e "${Cyan}Enabling I2C and 1-Wire Bus${NC}"
sudo raspi-config nonint do_i2c 0
echo -e "dtoverlay=w1-gpio\ndtoverlay=uart5\nenable_uart=1" | sudo tee -a /boot/config.txt
sudo debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF

# Set hostname to vanpi
echo -e "${Cyan}Set hostname to vanpi${NC}"
echo "pekaway" | sudo tee /etc/hostname

# saving needed resources to ~/pekaway
echo -e "${Cyan}saving needed resources to ~/pekaway${NC}"
mkdir ~/pekaway
cd pekaway
wget ${Server}home_pi_pekaway_files.zip
unzip ~/pekaway/home_pi_pekaway_files.zip
echo -e "${Cyan}making scripts executable${NC}"
find ~/pekaway/ -type f -iname "*.sh" -exec chmod +x {} \;
chmod 0744 ~/pekaway/availableWifi.txt
echo "yes" > ~/pekaway/firstboot

#install wiringpi
echo -e "${Cyan}Installing/updating wiringpi...${NC}"
cd /tmp
wget https://project-downloads.drogon.net/wiringpi-latest.deb
sudo dpkg -i wiringpi-latest.deb

# get and install needed packages list
echo -e "${Cyan}Saving list with needed packages${NC}"
cd ~/pekaway
wget ${Server}packages.txt
echo -e "${Cyan}Installing needed packages${NC}"
sudo apt install $(cat ~/pekaway/packages.txt) -y
sudo apt install python3-pip -y
sudo pip3 install adafruit-ads1x15 bottle

#install git
echo -e "${Cyan}Installing git${NC}"
sudo apt install git make build-essential

# install Node-Red including Node and npm
echo -e "${Cyan}Installing/updating Node-Red, Node and npm${NC}"
cd ~
echo -e "${Cyan}Please press y to continue!${NC}"
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) --node16 --confirm-install --confirm-pi
sudo systemctl enable nodered.service
echo -e "${Cyan}Starting Node-Red for initial setup...${NC}"
sudo systemctl start nodered.service
echo -e "${Cyan}Stopping Node-Red${NC}"
sudo systemctl stop nodered.service

#install Node-Red modules
echo -e "${Cyan}Installing/updating Node-Red modules...${NC}"
cd ~/.node-red
rm package.json
rm package-lock.json
wget ${Server}package.json
echo -e "${Cyan}Please stand by! This may take a while!${NC}"
echo -e "${Red}It may look frozen, but it is not! Please leave it running and wait patiently.${NC}"
echo -e "${Red}Go grab a coffee and relax for a while, I'll take care of the rest :)${NC}"
npm install

#install Node-Red Pekaway VanPi flows
echo -e "${Cyan}Installing/updating Node-Red Pekaway VanPi flows...${NC}"
cd ~/pekaway
wget ${Server}flows.json
cp flows.json ~/.node-red/flows_pekaway.json
cd ~/.node-red/node_modules/node-red-dashboard/dist
wget ${Server}icons.zip
mv ~/.node-red/node_modules/node-red-dashboard/dist/icon64x64.png ~/.node-red/node_modules/node-red-dashboard/dist/icon64x64_old.png
mv ~/.node-red/node_modules/node-red-dashboard/dist/icon120x120.png ~/.node-red/node_modules/node-red-dashboard/dist/icon120x120_old.png
mv ~/.node-red/node_modules/node-red-dashboard/dist/icon192x192.png ~/.node-red/node_modules/node-red-dashboard/dist/icon192x192_old.png
unzip icons.zip

# Install and configure Access Point
echo -e "${Cyan}Installing and configuring Access Point mode...${NC}"
cd ~/
sudo apt install hostapd dnsmasq -y
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
sudo cp /etc/dhcpcd.conf /etc/dhcpcd_nonap.conf
echo -e "\n interface wlan0 \n   static ip_address=192.168.4.1/24 \n   nohook wpa_supplicant" | sudo tee -a /etc/dhcpcd.conf
sudo cp /etc/dhcpcd.conf /etc/dhcpcd_ap.conf
echo -e "# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md \n# Enable IPv4 routing \nnet.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/routed-ap.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save
echo -e "# Listening interface\ninterface=wlan0\n# Pool of IP addresses served via DHCP\ndhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h\n# Local wireless DNS domain\ndomain=wlan\n# Alias for this router\naddress=/peka.way/192.168.4.1" | sudo tee /etc/dnsmasq.conf
sudo rfkill unblock wlan
echo -e "country_code=DE\ninterface=wlan0\n\nssid=PeKaWayControl\nhw_mode=g\nchannel=6\nmacaddr_acl=0\nauth_algs=1\nwpa=2\nwpa_passphrase=pekawayfetzt\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\n" | sudo tee /etc/hostapd/hostapd.conf

# Install and configure Nginx
echo -e "${Cyan}Installing and configuring Nginx${NC}"
sudo apt update && sudo apt install nginx -y
echo -e "server {\n   listen 80;\n   server_name peka.way pekaway.local vanpi.local van.pi;\n   location / {\n      proxy_pass http://127.0.0.1:1880/ui/;\n   }\n}\nserver {\n   listen 80;\n   server_name homebridge.peka.way hb.peka.way homebridge.van.pi hb.van.pi;\n   location / {\n      proxy_pass http://127.0.0.1:8581/;\n   }\n}" | sudo tee /etc/nginx/sites-available/pekaway1
sudo ln -s /etc/nginx/sites-available/pekaway1 /etc/nginx/sites-enabled/
sudo systemctl reload nginx
sudo systemctl enable nginx

# Install Mosquitto MQTT Server
echo -e "${Cyan}Installing Mosquitto MQTT Server${NC}"
sudo apt install mosquitto mosquitto-clients -y


# Install Homebridge
echo -e "${Cyan}Installing and configuring Homebridge for Apple Homekit${NC}"
sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x
sudo hb-service install --user homebridge
echo -e "${Cyan}Installing Mqttthing for Homebridge${NC}"
sudo -E -n npm install -g homebridge-mqttthing@latest
cd ~/pekaway
wget ${Server}config.json
sudo \cp -r ~/pekaway/config.json /var/lib/homebridge/config.json

# Clear files
echo -e "${Cyan}Clearing folders and files...${NC}"
sudo rm /tmp/wiringpi-latest.deb
sudo rm ~/pekaway/home_pi_pekaway_files.zip

# Restart Services
echo -e "${Cyan}Restarting services...${NC}"
sudo systemctl restart nginx.service homebridge.service mosquitto.service nodered.service
sed -i 's/flows.json/flows_pekaway.json/g' ~/.node-red/settings.js
sudo systemctl restart nodered.service

end=`date +%s`
enddate=`date`
runtime=$((end-start))
echo -e "-----------------------------------------"
echo -e "${Cyan}Script started: ${NC}${startdate}"
echo -e "${Cyan}Script ended: ${NC}${enddate}"
echo -e "${Red}Script runtime in Seconds: ${NC}${runtime}"

# Reboot Raspberry Pi
echo "Installation done, reboot needed!"
read -r -p "Do you want to reboot now? [Y/n] " input
 
case $input in
      [yY][eE][sS]|[yY])
            sudo reboot
            ;;
      [nN][oO]|[nN])
            echo "Aborting, please remember to reboot for the VanPi system to work properly!"
            exit 0
            ;;
      *)
            echo "Invalid input... please type 'sudo reboot' to reboot"
            exit 0
            ;;
esac
