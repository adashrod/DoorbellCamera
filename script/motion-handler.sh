#!/bin/bash

echo "`date +"%Y-%m-%dT%H-%M-%S"` motion event handler: $1"

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

haServerIp=`cat ${scriptDir}/../haServerIp.txt`
haServerPort=`cat ${scriptDir}/../haServerPort.txt`
haUnixUser=`cat ${scriptDir}/../haUnixUser.txt`
haVideoDir=`cat ${scriptDir}/../haVideoDir.txt`
webhookId=`cat ${scriptDir}/../webhookIdMotionVideo.txt`
idFile=`cat ${scriptDir}/../idFile.txt`

scp -i ${idFile} $1 ${haUnixUser}@${haServerIp}:${haVideoDir}/latestMotionVideo.mp4

if [ $? -eq 0 ]; then
    echo "calling motion webhook"
    curl -i -X POST http://${haServerIp}:${haServerPort}/api/webhook/${webhookId}
else
    echo "something went wrong sending file"
fi
