#!/usr/bin/env bash

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

if type -p java > /dev/null ; then
    # ensure JAVA_HOME is set for mkcert to install local root CA in the java trust store
    # see https://github.com/FiloSottile/mkcert#supported-root-stores
    if test -z ${JAVA_HOME} ; then
        if [[ $(uname -s) == Darwin ]] ; then
            echo -e "☕️ Running macOS and JAVA_HOME is not set. Attempting to set it..."
            export JAVA_HOME=$(/usr/libexec/java_home)
            echo -e "✅ JAVA_HOME now set to ${JAVA_HOME}"
        else
            echo -e "☕️ Java is installed but JAVA_HOME is not set. Set it before running this script."
            exit 1
        fi
    fi
else
    echo -e "☕️ Did not detect an installation of Java."
fi

NGINX_HOME=$(./locate-nginx.sh)
CERT_DIRECTORY=$HOME/.gu/mkcert

DOMAIN=$1

KEY_FILE=${CERT_DIRECTORY}/${DOMAIN}.key
CERT_FILE=${CERT_DIRECTORY}/${DOMAIN}.crt

mkcert -install

echo -e "🔐 Creating certificate for: ${YELLOW}${DOMAIN}${NC}"
mkdir -p ${CERT_DIRECTORY}
mkcert -key-file=${KEY_FILE} -cert-file=${CERT_FILE} ${DOMAIN}

echo -e "Symlinking the certificate for nginx at ${NGINX_HOME}"
ln -sf ${KEY_FILE} ${NGINX_HOME}/${DOMAIN}.key
ln -sf ${CERT_FILE} ${NGINX_HOME}/${DOMAIN}.crt

echo -e "🚀 ${YELLOW}Done. Please restart nginx.${NC}"
