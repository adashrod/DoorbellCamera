# DoorbellCamera

## Useful links
- [MotionEye](https://github.com/motioneye-project/motioneye)
- [MotionEyeOs](https://github.com/motioneye-project/motioneyeos)
- [HomeAssistant](https://www.home-assistant.io/integrations/)
- [HA PyScript](https://hacs-pyscript.readthedocs.io/en/latest/reference.html#pyscript-executor)

## Configurations
Camera: Raspberry Pi NoIR Camera Module V2

MotionEyeOs camera: Camera type: Local V4L2, Camera: MMAL (Need to enable "Legacy Camera" in `raspi-config` first)

## Install the daemons

Copy the systemd config files to the user's service directory

`pi-doorbell`: the daemon that listens for button presses
`speaker-keep-alive`: a daemon that regularly plays inaudible sound files on a bluetooth speaker to prevent auto-shut off

```bash
$ # install
$ pip3 install python-vlc
$ mkdir ~/.config/systemd/user
$ cp resource/pi-doorbell.service ~/.config/systemd/user/
$ cp resource/speaker-keep-alive.service ~/.config/systemd/user/
$ # create log file and change owner
$ sudo touch /var/log/doorbell.log
$ sudo chown <user>:<user> /var/log/doorbell.log
$ sudo chmod 664 /var/log/doorbell.log
$ # turn services on
$ systemctl --user enable pi-doorbell.service
$ systemctl --user start pi-doorbell.service
$ systemctl --user enable speaker-keep-alive.service
$ systemctl --user start speaker-keep-alive.service
$ # check status
$ systemctl --user status pi-doorbell.service
$ systemctl --user status speaker-keep-alive.service
$ journalctl --user-unit pi-doorbell.service
$ journalctl --user-unit speaker-keep-alive.service
```

### Optional: install webhook server daemon

```bash
$ cp resource/wh-server.service ~/.config/systemd/user/
$ systemctl --user enable wh-server.service
$ systemctl --user start wh-server.service
$ systemctl --user status wh-server.service
$ journalctl --user-unit wh-server.service
```

### Install [bluetooth-autoconnect](https://github.com/jrouleau/bluetooth-autoconnect)

Once the desktop is disabled, Raspberry Pi OS might not automatically reconnect to trusted, paired bluetooth devices at boot.

Follow installation instructions and enable as a daemon using `systemctl`

### Install Health Checker

```bash
$ crontab -e
$ # add an entry for the full path to script/check-daemon.sh
```

## Runtime Configuration Files

#### These are used for storing configuration data used by various scripts. The scripts expect them to be in the main directory of the repo

|file|contents|use|
|-|-|-|
|doorbellOnlineVarName.txt|name of variable for key-value storage|store result of check-health.sh|
|haServerIp.txt|IP of Home Assistant|for triggering webhooks|
|haServerPort.txt|port of HA||
|kvServerIp.txt|IP of key-value server|storing result of check-health.sh||
|kvServerPort.txt|port of KV||
|motionEyeServerIp.txt|IP of MotionEye|for constructing URLs in webhook payloads|
|motionEyeServerPort.txt|port of ME||
|webhookIdHealthAlert.txt|HA webhook ID|triggered when check-health.sh detects a failure|
|webhookIdMotionVideo.txt|HA webhook ID|triggered by ME when a motion video has been captured|
|webhookIdPress.txt|HA webhook ID|triggered by rpi-main.py on button press|
|cameraDir.txt|directory where ME stores files||
|cameraId.txt|numeric ID of the camera||
