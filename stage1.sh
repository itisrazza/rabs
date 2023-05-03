#!/bin/bash

source "./helpers.sh"

main() {
    preamble
    disk_format
    install_base
    install_stage2
    complete
}

#
# Sections
#

preamble() {
    section "Welcome"
    echo
    echo "Welcome to Razza's Arch Linux Bootstrap script."
    echo
    echo "Before you begin, please make sure you've done some preflight tasks:"
    echo "- You are connected to the internet."
    echo "- Install target drive is connected."
    echo "- LVM volumes on the drive are disabled."
    echo

    echo "Press Ctrl+C to cancel and exit."
    echo -n "Press ENTER to continue."

    read -r -s
}

disk_format() {
    while [ -z "${DISK_LABEL}" ] || [ "${DISK_CONFIRM}" != "YES" ]; do
        select_disk
        confirm_disk
    done

    perform_format
}

install_base() {
    section "Installing Essential Packages"
    return
    
    xargs pacstrap -K /mnt < packages-stage1.txt || fatal "Failed to install essential packages."
    genfstab -U /mnt >> /mnt/etc/fstab || fatal "Failed to create /etc/fstab."
}

install_stage2() {
    section "Configuring System"
    return

    cp -r . /mnt/root/.archbs || fatal "Failed to copy installer files onto root drive."
    arch-chroot /mnt/root/.archbs/stage2.sh || failed "Failed to run installer on chroot."
}

complete() {
    section "Installation Complete"
    echo
    echo "The installation should now be complete. You can continue setting up"
    echo "Arch Linux in a chroot, or restart the computer to boot into your new"
    echo "installation."
    echo
    echo "Chroot into the installation:"
    echo "  $ arch-chroot /mnt"
    echo
    echo "Restart the computer:"
    echo "  $ reboot"
    echo
}

#
# Disk Formatting
#

select_disk() {
    while [ -z "${DISK_LABEL}" ]; do
        section "Disk Formatting"
        echo
        echo "The following disks are available:"
        lsblk --output NAME,SIZE,MODEL,TYPE | grep disk | sed -E 's/^(\S+)\s+(\S+?)\s+(.+?)\s+disk$/  - \1 - \2 (\3)/'
        echo

        read -r -p "Enter the disk label: " DISK_LABEL_INPUT
        validate_disk "${DISK_LABEL_INPUT}"
    done
}

confirm_disk() {
    section "Disk Formatting"
    echo
    echo "The storage device '${DISK_LABEL}' is going to be deleted with data being"
    echo "no longer recoverable. Type 'YES' and press ENTER to continue."
    echo
    fdisk -l "${DISK_LABEL}"
    echo
    read -r -p "Write 'YES' to continue. Ctrl+C to exit.: " DISK_CONFIRM
    
    if [ "$DISK_CONFIRM" == "YES" ]; then
        export DISK_CONFIRM="YES"
    else
        export DISK_CONFIRM=""
        export DISK_LABEL=""
    fi
}

perform_format() {
    section "Disk Formatting"

    echo "Formatting ${DISK_LABEL}"

    echo "Create new parition layout"

    get_part 0
    local part1="$GET_PART_RET"

    get_part 1
    local part2="$GET_PART_RET"

    get_part 2
    local part3="$GET_PART_RET"

    echo "Format ESP partition - FAT32 @ ${part1}"
    echo "Format boot partition - ext4 @ ${part2}"
    echo "Format / partition as LUKS @ ${part3}"
    echo "Format LUKS partitions as btrfs"
    
    echo "Mount btrfs partition -> /"
    echo "Create btrfs subvolumes"
    echo "  /home"
    echo "  /root"
    echo "  /snapshots"

    echo "Unmount btrfs partition"
    echo "Remount btrfs /root subvolume"

    echo "Mount boot parition       -> /boot"
    echo "Mount ESP parition        -> /boot/efi"
    echo "Mount home subvolume      -> /home"
    echo "Mount snapshots subvolume -> /snapshots"

    echo "Create swap partition -> /snapshots/.swap"
    echo "Mount swap partition"
}

validate_disk() {
    file "/dev/${DISK_LABEL_INPUT}" | grep "block special"
    if [ $? -eq 0 ]; then
        export DISK_LABEL="/dev/${DISK_LABEL_INPUT}"
        echo "OK!"
    else
        echo "NOT OK!"
    fi
}

get_part() {
    export GET_PART_RET
    GET_PART_RET="$(fdisk -l "${DISK_LABEL}" | awk "NR==$((10 + $1))" | awk '{ print $1; }')"
}

assert_root
main
