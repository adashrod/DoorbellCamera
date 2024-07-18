#!/bin/bash

# For bluetooth speakers that automatically shut off after X minutes of inactivity, use this to
# play an inaudible audio file that should prevent auto-shut off
# this also attempts to reconnect or reboot if the speaker is disconnected

# at boot, sleep for a while to give the system plenty of time to start before ever trying to reboot
sleep 600

macAddress=$(cat Applications/DoorbellCamera/btSpeakerMacAddress.txt)

# recursively tests the status of the speaker connection
# if the speaker is connected, it plays a silent sound
# if the speaker isn't connected, the recursive calls attempt to fix the speaker by
# 1: reconnecting to the speaker
# 2: power-cycling the speaker
# 3: rebooting the machine
# @param $1 step to attempt if disconnected (connect|power|reboot)
tryToPlayOrReconnect() {
    # info prints <not available> when the device is unpaired,
    # <Connected: yes> when connected
    # and <Connected: no> when visible and not connected, or paired and invisible
    yesCount=$(bluetoothctl info $macAddress | grep -c "Connected: yes")
    noCount=$(bluetoothctl info $macAddress | grep -c "Connected: no")
    if [ $yesCount -ge 1 ]
    then
        /usr/bin/cvlc /home/doorb/Applications/DoorbellCamera/src/ringtones/Silence5s.mp3 vlc://quit
    elif [ $noCount -ge 1 ]
    then
        if [ $1 = "connect" ]
        then
            echo "speaker-keep-alive: attempting to reconnect"
            bluetoothctl connect $macAddress
            sleep 10
            tryToPlayOrReconnect "power"
        elif [ $1 = "power" ]
        then
            echo "speaker-keep-alive: attempting to power cycle"
            bluetoothctl power off
            sleep 10
            bluetoothctl power on
            sleep 10
            tryToPlayOrReconnect "reboot"
        elif [ $1 = "reboot" ]
        then
            echo "speaker-keep-alive: attempting to reboot"
            sudo shutdown -r
        else
            echo "speaker-keep-alive: tryToPlayOrReconnect called w/ other arg"
        fi
    else
        echo "speaker-keep-alive: speaker not paired; noop"
    fi
}

while :
do
    tryToPlayOrReconnect "connect"
    sleep 300
done
