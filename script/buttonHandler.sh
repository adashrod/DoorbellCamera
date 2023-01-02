#!/bin/bash

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

python3 src/main.py `cat $scriptDir/../haServerIp.txt`:`cat $scriptDir/../haServerPort.txt` `cat $scriptDir/../webhookIdPress.txt`

