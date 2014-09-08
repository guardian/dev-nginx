#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
nginxHome=`./locate-nginx.sh`

sudo ln -fs $DIR/tools.crt $nginxHome/tools.crt
sudo ln -fs $DIR/tools.key $nginxHome/tools.key

sudo ./restart-nginx.sh
