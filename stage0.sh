#!/bin/bash

#
# itisrazza/archbs bootstrap
#

if [ "${EUID}" -ne 0 ]; then
    echo "This script needs to be executed as root."
    exit 1
fi
