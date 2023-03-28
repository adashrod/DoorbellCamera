#!/bin/bash

# event handler for file creation in MotionEye

echo "`date +"%Y-%m-%dT%H-%M-%S"` motion event handler: $1"

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

motionEyeServerIp=`cat ${scriptDir}/../motionEyeServerIp.txt`
motionEyeServerPort=`cat ${scriptDir}/../motionEyeServerPort.txt`
haServerIp=`cat ${scriptDir}/../haServerIp.txt`
haServerPort=`cat ${scriptDir}/../haServerPort.txt`
webhookId=`cat ${scriptDir}/../webhookIdMotionVideo.txt`
cameraDir=`cat ${scriptDir}/../cameraDir.txt`
cameraId=`cat ${scriptDir}/../cameraId.txt`

if [[ "$1" == *"mp4" ]]; then
    if [[ "$1" == "${cameraDir}"* ]]; then
        dirNameLength=${#cameraDir}
        fileName=${1:$dirNameLength}
        url="http://${motionEyeServerIp}:${motionEyeServerPort}/movie/${cameraId}/download${fileName}"
        echo "calling motion webhook"
        curl -i -X POST -H "Content-Type: application/json" -d "{\"videoUrl\":\"${url}\"}" http://${haServerIp}:${haServerPort}/api/webhook/${webhookId}
        if [ $? -ne 0 ]; then
            echo "something went wrong calling webhook"
        fi
    else
        echo "something went wrong; created file ($1) is not in the expected directory ($cameraDir)"
    fi
else
    echo "created file is not a video, ignoring"
fi
