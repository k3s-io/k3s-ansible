# Load Balancer PI setup

## SD Cards

For each LB pi card (you can setup all cards at the same time)

- Install Raspbian Lite using Raspberry Pi Imager (https://www.raspberrypi.org/software/)
- Create empty file named `ssh` in the SD card
- Create `wpa_supplicant.conf` in the SD card, content:

```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=<YOUR_COUNTRY_CODE_HERE>
update_config=1

network={
 ssid="<YOUR_SSID_HERE>"
 psk="<YOUR_PASSWORD_HERE>"
}
```

## PI Network setup

We need to do these operations by turning on one PI at a time, otherwise the `raspberrypi.local` name will collide.

If you have well-know IP addresses you can turn on all PIs together and use the IP address instead of `raspberrypi.local`

- Start the PI, it will become available on `raspberrypi.local` hostname
- `ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null pi@raspberrypi.local` (default pi user password is `raspberry`)
- `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 'pi@raspberrypi.local'` (options avoid saving the host key locally)
- Run `sudo raspi-config` and update the hostname under section `System Options` => `Hostname` (the 2 lb PIs hostname be `lb1` and `lb2`)
- Feel free to do other customisation (e.g. update bootstrap firmware on PI4)
- Suggested: run a `sudo apt-get update` and a `sudo apt-get dist-upgrade`. This will avoid a couple of issues you might find in the notes.
- Reboot

Now the PIs are available using `lb1.local` and `lb2.local` hostnames

## Load Balancer PIs provisioning

Run:
```bash
pipenv run ansible-requirements
pipenv run lb_bootstrap
```

Note: the step `TASK [apt_dependencies : Run apt dist-upgrade]` might take a while (~10-15 minutes if system is not up to date)

Note: if you get the error `Failed to initialize nft: Protocol not supported` just run:

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 'pi@lb1.local'
sudo reboot
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 'pi@lb2.local'
sudo reboot
```

then run `pipenv run lb_bootstrap` again. It happens when the kernel is changed (by `dist-upgrade`) but system has not been yet rebooted. 