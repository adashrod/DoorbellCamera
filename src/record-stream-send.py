#!/bin/bash

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
fileName=`date +"%Y-%m-%d/%H-%M-%S"`
# vlc has --run-time and --stop-time parameters that should stop the stream, but they don't seem to work here, so use timeout instead
# todo:aaron this script should run on the HA server since it will be invoked by the telegram bot
timeout 30 vlc -I dummy `cat ${scriptDir}/../streamUrl.txt` --sout=file/mp4:${tbd}/${fileName}.mp4
