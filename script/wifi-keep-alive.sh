#!/bin/bash

# Attempts to restart the wifi adapter or reboot if no internet connection is detected

# at boot, sleep for a while to give the system plenty of time to start before ever trying to reboot
sleep 600

# recursively tests the status of the internet connection
# if the internet is connected, do nothing
# if the internet isn't connected, the recursive calls attempt to fix the connection by
# 1: restarting the wifi service
# 2: rebooting the machine
# @param $1 step to attempt if disconnected (connect|reboot)
tryToConnectOrReboot() {
    ping -c 1 -q 192.168.1.1 >&/dev/null
    if [ $? -ne 0 ]
    then
        if [ $1 = "connect" ]
        then
            echo "wifi-keep-alive: attempting to reconnect"
            sudo systemctl restart wpa_supplicant.service
            sleep 60
            tryToConnectOrReboot "reboot"
        elif [ $1 = "reboot" ]
        then
            echo "wifi-keep-alive: attempting to reboot"
            sudo shutdown -r
        fi
    else    
        echo "wifi-keep-alive: test success"
    fi
}

while :
do
    tryToConnectOrReboot "connect"
    sleep 300
done
