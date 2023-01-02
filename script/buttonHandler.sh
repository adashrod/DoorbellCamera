#!/bin/bash

scriptDir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

python3 src/main.py `cat $scriptDir/../haHost.txt` `cat $scriptDir/../webhookIdPress.txt`

