#!/bin/bash

#
# Razza's Arch Bootstrap Script
#
# This is the entry point to "Razza's Arch Installation System", which runs
# from the Arch Linux ISO, and completed the installation for you.
#
# For more information on this script:
#   https://rabs.razza.io/
#
# This is for my own use. If you want to set up Arch Linux for yourself, see:
#   https://wiki.archlinux.org/title/Installation_guide
#
# I'm welcoming issues and pull requests, and making this script generally better.
#   https://github.com/itisrazza/rabs
#

#
# Stage 0: Decompress and execute
#
# This file starts with a bash script that dd's the archive out of this file
# and executes Stage 1.
#

if [ "${EUID}" -ne 0 ]; then
    echo "This script needs to be executed as root."
    exit 1
fi

if [ "$0" != "./rabs-install" ]; then
    echo "This program needs to be called from within it's own directory."
    echo "Program path is expected to be \"./rabs-install\", not \"$0\"."
    echo
    
    exit 1
fi

dd if="$0" bs=@BLOCK_SIZE@ skip=@SCRIPT_BLOCKS@ 2>/dev/null | tar xf -
if [ $? -ne 0 ]; then
    echo "Failed to extract installer."
    exit 1
fi

cd rabs && exec ./stage1.sh

exit 1
# explicitly exit here
# compressed archive follows
