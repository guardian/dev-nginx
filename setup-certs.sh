#!/bin/bash

# Create a certificate using mkcert. Assumes you have installed mkcert previously.
# Will add the CA to the truststore for macOS, Firefox and Java.

set -e

# colours
YELLOW='\033[1;33m'
NC='\033[0m' # no colour - reset console colour

if [[ $# -lt 1 ]]
then
    echo -e "Create a certificate for ${YELLOW}development use only${NC} using mkcert."
    echo -e "See https://github.com/FiloSottile/mkcert for more information."
    echo
	echo "Example usage: $0 foo.local"
	exit 1
fi

mac() {
  [[ ${SYSTEM} == 'Darwin' ]]
}

installed() {
  hash "$1" 2>/dev/null
}

# we're on a mac and have java installed, we can set JAVA_HOME
if mac && installed java; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

NGINX_HOME=$(./locate-nginx.sh)
CERT_DIRECTORY=$HOME/.gu/mkcert

DOMAIN=$1

KEY_FILE=${CERT_DIRECTORY}/${DOMAIN}.key
CERT_FILE=${CERT_DIRECTORY}/${DOMAIN}.crt

mkcert -install

echo -e "🔐 Creating certificate for: ${YELLOW}$@${NC}"
mkdir -p ${CERT_DIRECTORY}
mkcert -key-file=${KEY_FILE} -cert-file=${CERT_FILE} ${DOMAIN}

echo -e "Symlinking the certificate for nginx at ${NGINX_HOME}"
ln -sf ${KEY_FILE} ${NGINX_HOME}/${DOMAIN}.key
ln -sf ${CERT_FILE} ${NGINX_HOME}/${DOMAIN}.crt

echo -e "🚀 ${YELLOW}Done. Please restart nginx.${NC}"
