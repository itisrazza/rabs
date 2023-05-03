#!/bin/bash

#
# itisrazza/archbs bootstrap
#

DOWNLOAD_URL="@DOWNLOAD_URL@"
FOLDER_NAME="archbs-main"

if [ "${EUID}" -ne 0 ]; then
    echo "This script needs to be executed as root."
    exit 1
fi

curl -# -o "archbs.tar.gz" "${DOWNLOAD_URL}"
if [ $? -ne 0 ]; then
    echo "Couldn't download installer."
    exit 1
fi

tar xf archbs.tar.gz