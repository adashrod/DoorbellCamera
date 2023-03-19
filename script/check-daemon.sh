#!/bin/bash

# health check script to ensure that button-handler.sh is running. button-handler.sh should be installed as a systemd
# service using `/resource/pi-doorbell.service`

# necessary because cron doesn't have a full shell with env vars
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$(id -u "$LOGNAME")"/bus
export XDG_RUNTIME_DIR=/run/user/"$(id -u "$LOGNAME")"

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
haServerIp=`cat $scriptDir/../haServerIp.txt`
haServerPort=`cat $scriptDir/../haServerPort.txt`
kvServerIp=`cat $scriptDir/../kvServerIp.txt`
kvServerPort=`cat $scriptDir/../kvServerPort.txt`
webhookId=`cat $scriptDir/../webhookIdHealthAlert.txt`
doorbellOnlineVarName=`cat $scriptDir/../doorbellOnlineVarName.txt`

systemctl --user status pi-doorbell.service 2>&1 1>/dev/null

if [ $? -eq 0 ]; then
    echo "check doorbell daemon: online"
    curl -X POST -H "Content-Type: text/plain" -d `date --iso-8601=minutes` http://${kvServerIp}:${kvServerPort}/api/v1/keyValue/${doorbellOnlineVarName}
else
    echo "check doorbell daemon: offline"
    curl -X DELETE http://${kvServerIp}:${kvServerPort}/api/v1/keyValue/${doorbellOnlineVarName}
    curl -X POST -H "Content-Type: application/json" -d '{"message":"Doorbell Daemon: Doorbell button daemon is offline"}' http://${haServerIp}:${haServerPort}/api/webhook/${webhookId}
fi
