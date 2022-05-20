# Manually installing the VanPi system

- Get a clean install of Raspberry Pi OS Lite (Debian 11 bullseye!)  on a MicroSD-card - ([click here](https://www.raspberrypi.com/software/operating-systems/))
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


- Put the SD-card into the RPI4 and power it on (first boot may take up to a few minutes)
- Wait until it shows up in your network and login via SSH with the credentials you just set
- Once logged in do
```
    cd ~/ &&
    wget https://git.pekaway.de/Vincent/vanpi/-/raw/main/pi4_bullseye/vanpi-init.sh &&
    chmod +x vanpi-init.sh &&
    bash vanpi-init.sh
```

- The script will take about 10-15min to run through
- Confirm if inputs are needed
- Sit back and relax

Once done, the RPI will power up in Access Point Mode, connect to it and proceed from there
(You can just turn off the Access Point because we already configured wifi during the flashing process)

(Homebridge needs to be setup, you can do that under RPI-IP:8581 or pekaway.local:8581 - set vanpi:pekawayfetzt and continue from there, config should already be there, not further tested due to lack of iPhones)
