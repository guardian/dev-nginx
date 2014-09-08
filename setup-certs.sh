#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
nginxHome=`./locate-nginx.sh`

# copy all files in ssl/ into the nginx home
ls ssl | while read f
do
    sudo ln -fs "$DIR/ssl/$f" "$nginxHome/$f"
done

sudo ./restart-nginx.sh
