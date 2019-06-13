#!/usr/bin/env bash

set -e

OUTPUT_DIR=target
TAR_FILE=${OUTPUT_DIR}/dev-nginx.tar.gz
REPORT_FILE=${OUTPUT_DIR}/report.txt

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

tar -zcf ${TAR_FILE} bin script
SHA256=$(shasum -a 256 ${TAR_FILE})

echo -e "$(date)\n${SHA256}" >> ${REPORT_FILE}

cat ${REPORT_FILE}
