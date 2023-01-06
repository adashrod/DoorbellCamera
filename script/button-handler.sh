#!/bin/bash

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
haServerIp=`cat $scriptDir/../haServerIp.txt`
haServerPort=`cat $scriptDir/../haServerPort.txt`
webhookId=`cat $scriptDir/../webhookIdPress.txt`

python3 ${scriptDir}/../src/rpi-main.py ${haServerIp}:${haServerPort} ${webhookId}
