# Manually installing the VanPi system

- Get a clean install of Raspberry Pi OS Lite (Debian 11)  on a MicroSD-card - ([click here](https://www.raspberrypi.com/software/operating-systems/)) 

**_On bullseye the ads script is not working out of the box! Use buster instead! (the installation script works on both versions)_**

 - Using the Raspberry Pi Imager ([click here](https://www.raspberrypi.com/software/)), set the following options
    - Hostname: pekaway.local
    - activate ssh
    - username: vanpi
    - password: pekawayfetzt
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

- The script will take about 10-20min to run through, depending on bandwith and hardware
- Confirm if inputs are needed (none on bullseye, one on buster -> script works for both)
- Sit back and relax

Once done, the RPI will power up in Access Point Mode, connect to it and proceed from there
(You can just turn off the Access Point because we already configured wifi during the flashing process)

(Homebridge needs to be setup, you can do that when accessing RPI-IP:8581 or pekaway.local:8581 - set vanpi:pekawayfetzt and continue from there, config should already be there (or you can find it [here](https://git.pekaway.de/Vincent/vanpi/-/blob/main/pi4_bullseye/config.json)), not further tested
