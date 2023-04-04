#!/bin/bash

# For bluetooth speakers that automatically shut off after X minutes of inactivity, use this to
# play an inaudible audio file that should prevent auto-shut off

while :
do
    /usr/bin/cvlc /home/doorb/Applications/DoorbellCamera/src/ringtones/Silence5s.mp3 vlc://quit
    sleep 300
done

