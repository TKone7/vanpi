# Manually installing the VanPi system

- Get a clean install of Raspberry Pi OS Lite (Debian 11)  on a MicroSD-card - ([download here](https://www.raspberrypi.com/software/operating-systems/)) 

**_On bullseye the ads script is not working out of the box! Use buster instead! (the installation script works on both versions)_**

 - Using the Raspberry Pi Imager ([download here](https://www.raspberrypi.com/software/)), set the following options
    - Hostname: pekaway.local
    - activate ssh
    - username: pi
    - password: raspberry
    - wifi:
        - Your wifi SSID and passphrase
        - change wifi country if needed
    - change language if needed
    - change keyboardlayout if needed

- Flash the operating system to your sd card


- Put the SD-card into the RPI4 and power it on (first boot may take a few minutes)
- Wait until it shows up in your network and login via SSH with the credentials you just set
- Once logged in do
```
cd ~/ &&
wget https://git.pekaway.de/Vincent/vanpi/-/raw/main/pi4/vanpi-init.sh &&
chmod +x vanpi-init.sh &&
bash vanpi-init.sh
```

- The script will take about 10-20min to run through, depending on bandwith and hardware (20+ min on RPI3)
- Confirm if inputs are needed (none on bullseye, one on buster -> script works for both)
- Sit back and relax

Once done, the RPI will power up in Access Point Mode, connect to it and proceed from there
(You can just turn off the Access Point because we already configured wifi during the flashing process)

Homebridge needs to be setup, you can do that when accessing RPI-IP:8581 or pekaway.local:8581 - set admin:pekawayfetzt (or whatever you prefer) and continue from there, config should already be there (or you can find it [here](https://git.pekaway.de/Vincent/vanpi/-/blob/main/pi4/config.json)) - not further tested!!

Go to the frontend of the VanPi system > Config > Wifi and click on reset Homebridge. That will generate a new random MAC address, a new Pin code and it'll download the latest homebridge config from our server and deploy it. Remember that you need to be connected to the internet for Apple Home to work (and for downloading the config files, obviously)

## **THROUBLESHOOTING**

In case some symbols in the frontend are not displayed correctly (eg. "°C"), download the flows.json from the pi4 folder ([here](https://git.pekaway.de/Vincent/vanpi/-/blob/main/pi4/flows.json)).
On your RPI open ~/.node-red/flows_pekaway.json and manually replace its content with the content from the file you just downloaded from the server. Then restart Node-Red with "sudo systemctl restart nodered.service".

Alternatively, go into the Node-Red backend and replace non-formatted characters by hand:
 - flow Sensor-Dashboard, on the very top there are 4 text nodes displaying the temp sensors
 - flow Monit, aghain there are 4 nodes for the temp sensors and 1 gauge node for the CPU-temp
 - flow Config, at "system settings" 4 text nodes for the four temp sensors
