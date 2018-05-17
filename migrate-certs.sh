#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
nginxHome=`./locate-nginx.sh`

green='\x1B[0;32m'
red='\x1B[0;31m'
plain='\x1B[0m' # No Color

echo -e "${green}Migrating to Guardian Digital CA certificates${plain}"

removeOldCerts() {
    rm -f "$nginxHome/GNM-DC1-intermediate.crt"
    rm -f "$nginxHome/GNM-root-cert.pem"

    rm -f "$nginxHome/star.local.dev-gutools.co.uk.chained.crt"
    rm -f "$nginxHome/star.local.dev-gutools.co.uk.crt"
    rm -f "$nginxHome/star.local.dev-gutools.co.uk.key"

    rm -f "$nginxHome/star.media.local.dev-gutools.co.uk.chained.crt"
    rm -f "$nginxHome/star.media.local.dev-gutools.co.uk.crt"
    rm -f "$nginxHome/star.media.local.dev-gutools.co.uk.key"
}

linkCerts() {
    # copy all files in ssl/ into the nginx home
    ls ssl | while read f
    do
        sudo ln -fs "$DIR/ssl/$f" "$nginxHome/$f"
    done
}

updateConfFiles() {
    sites_enabled="${nginxHome}/sites-enabled"

    oldcert1="star.local.dev-gutools.co.uk.chained.crt"
    oldcert2="star.media.local.dev-gutools.co.uk.chained.crt"
    newcert="star.local.dev-gutools.co.uk.crt"

    oldkey1="star.media.local.dev-gutools.co.uk.key"
    newkey="star.local.dev-gutools.co.uk.key"

    ls ${sites_enabled} | while read f
    do
        sed -i '' "s/${oldcert1}/${newcert}/g" ${sites_enabled}/$f
        sed -i '' "s/${oldcert2}/${newcert}/g" ${sites_enabled}/$f
        sed -i '' "s/${oldkey1}/${newkey}/g" ${sites_enabled}/$f
    done
}

removeOldCerts
linkCerts
updateConfFiles

sudo ./restart-nginx.sh

echo -e "${green}Done${plain}"
