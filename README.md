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

- when flash is done:
    - open the boot partition and in cmdline.txt delete everything in front of "root=PARTUUID=..."
    - file should look like this:
        - root=PARTUUID=7d5a2870-02 rootfstype=ext4 fsck.repair=yes rootwait quiet init=/usr/lib/raspi-config/init_resize.sh systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target

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

(Homebridge needs to be setup, you can do that under RPI-IP:8581 or pekaway.local:8581 - set vanpi:pekawayfetzt and continue from there, config should already be there, not further tested due to lack of iPhones)
