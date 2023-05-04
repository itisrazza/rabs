#!/bin/bash

#
# Stage 2: OS Installation and Configuration
#
# This file completes the remaining steps of installing the remaining packages
# and performing initial system setup.
#

source "./helpers.sh"

main() {
    set_timezone
    set_hardware_clock
    set_locale
    set_hostname
    setup_users
    install_packages
    system_config
    setup_initramfs
    install_boot_loader
}

#
# Default options
#

export TIMEZONE="Pacific/Auckland"
export HWCLOCK_USE_LOCALTIME=""

#
# Sections
#

set_timezone() {
    section "Configuring Time Zone"
    echo
    echo "The ability to set a time zone is currently not implemented."
    echo "This only option at the moment is: Pacific/Auckland"
    echo 
    echo "You may change it after the system is installed if need be."
    read -r -s
}

set_hardware_clock() {
    section "Configuring Hardware Clock"
    echo
    echo "The hardware clock keeps track of the time while the system is shut down."
    echo "Linux by default keeps the clock at UTC, which may cause problems on systems"
    echo "dual-booting with Windows, which keeps at local time."
    echo
    echo "If you want the hardware clock to be set to local time, type 'local' below."
    read -r -p "Clock alignment [utc]: "
}

set_locale() {
    section "Configuring Locale"
    echo
    echo "The ability to set a locale is currently not implemented."
    echo "The only option at the moment is: en_NZ.UTF-8"
    echo
    echo "The following locales are also made available:"
    echo "  - en_US.UTF-8"
    echo "  - en_GB.UTF-8"
    echo "  - en_AU.UTF-8"
    echo "  - ro_RO.UTF-8"
    echo
    read -r -s
}

set_hostname() {
    section "Configuring Computer Name"
    echo
    echo "Enter the name you'd like to use for this computer."
    echo
    read -r -p "Hostname [localhost]: "
}

setup_users() {
    section "Configuring User"
    echo
    echo ""
    echo
    read -r -s
}

install_packages() {
    section "Installing Packages"
    echo
    read -r -s
}

system_config() {
    section "Configuring System"
    echo
    read -r -s
}

setup_initramfs() {
    section "Configuring Initramfs"
    read -r -s
}

install_boot_loader() {
    section "Installing Boot Loader"
    read -r -s
}

#
# Timezone
#

#
# Hardware Clock
#

#
# Locale
#

#
# Hostname
#

#
# User Accounts
#

#
# Packages
#

#
# System Configuration
#

#
# Setup initramfs
#

#
# Install bootloader
#

#
# Entry point
#

assert_root
main
