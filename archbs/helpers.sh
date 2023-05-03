#!/bin/bash

#
# Bash script utilities
#

##
# section <title>
#
# Prints a section title.
#
section() {
    clear
    echo -e "==> ${1}"
}

##
# fatal <message> [exitcode]
#
# Prints an error message and exits the script.
#
fatal() {
    echo -e "FATAL: ${1}"
    exit "${2:-1}"
}

assert_root() {
    [ "${EUID}" -eq 0 ] && return
    fatal "This script needs to be executed as root."
}
