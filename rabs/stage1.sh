#!/bin/bash

#
# Stage 1: Disk formatting and Arch Linux bootstrap
#
# This file formats the disk, installs the essential Arch Linux packages,
# and hands off control to Stage 2.
#

source "./helpers.sh"

main() {
    preamble
    check_deps
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
    echo "- You have booted in UEFI mode."
    echo "- You are connected to the internet."
    echo "- Install target drive is connected."
    echo "- LVM volumes on the drive are disabled."
    echo

    echo "Press Ctrl+C to cancel and exit."
    echo -n "Press ENTER to continue."

    read -r -s
}

check_deps() {
    if [ ! -d /sys/firmware/efi/efivars ]; then
        fatal "Missing UEFI firmware"
    fi
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
    echo
    xargs pacstrap -K /mnt < packages-stage1.txt || fatal "Failed to install essential packages."
    genfstab -U /mnt >> /mnt/etc/fstab || fatal "Failed to create /etc/fstab."
}

install_stage2() {
    section "Configuring System"
    echo
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
    format_gpt || fatal "Failed to create partition layout."

    format_esp || fatal "Failed to format EFI system parititon."
    format_boot_part || fatal "Failed to format boot partition."
    format_root_part || fatal "Failed to format root partition."
    create_root_subvol || fatal "Failed to create root subvolumes."

    mount_target_fs || fatal "Failed to mount target file systems."
    create_swapfile || fatal "Failed to create swap file."
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

format_gpt() {
    section "Disk Formatting"
    echo
    echo "Creating new partition table."
    echo

    fdisk -w always -W always "${DISK_LABEL}" < fdisk.lst
    return $?
}

format_esp() {
    get_part 0
    local part_label="$GET_PART_RET"

    section "Disk Formatting"
    echo
    echo "Formatting EFI system partition."
    echo
    mkfs.fat -F 32 -n ESP "${part_label}"
    return $?
}

format_boot_part() {
    get_part 1
    local part_label="$GET_PART_RET"

    section "Disk Formatting"
    echo
    echo "Formatting boot partition."
    echo
    mkfs.ext4 -L "linux-boot" "${part_label}"
    return $?
}

format_root_part() {
    get_part 2
    local part_label="$GET_PART_RET"

    format_root_part_askpass
    section "Disk Formatting"
    echo
    echo "Formatting root partition."
    echo
    echo -n "${DISK_ENCRYPT_KEY}" | cryptsetup luksFormat -d - "${part_label}" || return $?
    echo -n "${DISK_ENCRYPT_KEY}" | cryptsetup open -d - "${part_label}" sysroot || return $?
    mkfs.btrfs -L linux-root /dev/mapper/sysroot
    return $?
}

format_root_part_askpass() {
    while [ -z "$DISK_ENCRYPT_KEY" ]; do
        section "Disk Formatting"
        echo
        echo "You may now pick a password for the system partition."
        echo "This password will be requested every time this computer starts up."
        echo
        echo "You may also leave a blank password, where you can set it up later."
        echo
        
        read -r -s -p "Encryption password: " enc_pass
        echo
        read -r -s -p "Encrpytion password (again): " enc_pass_again
        echo

        if [ "$enc_pass" != "$enc_pass_again" ]; then
            echo -n "Passwords mismatch."
            read -r -s
        else
            DISK_ENCRYPT_KEY="$enc_pass"
            export DISK_ENCRYPT_KEY
        fi
    done
}

create_root_subvol() {
    section "Disk Formatting"
    echo
    echo "Creating subvolumes."
    echo

    mount /dev/mapper/sysroot /mnt || return $?
    btrfs subvolume create /mnt/root || return $?
    btrfs subvolume create /mnt/home || return $?
    btrfs subvolume create /mnt/snapshots || return $?

    umount -R /mnt
    return $?
}

mount_target_fs() {
    get_part 0
    local esp_part_label="$GET_PART_RET"
    get_part 1
    local boot_part_label="$GET_PART_RET"
    
    section "Disk Formatting"
    echo
    echo "Mounting file systems."
    echo
    mount -o subvol=/root /dev/mapper/sysroot /mnt || return $?
    mkdir -p /mnt/boot /mnt/home /mnt/snapshots || return $?
    mount -o subvol=/home      /dev/mapper/sysroot /mnt/home || return $?
    mount -o subvol=/snapshots /dev/mapper/sysroot /mnt/snapshots || return $?
    mount "${boot_part_label}" /mnt/boot || return $?
    mkdir -p /mnt/boot/efi || return $?
    mount "${esp_part_label}" /mnt/boot/efi || return $?
}

create_swapfile() {
    echo "Create swap file -> /snapshots/.swap"
    echo "Mount swap file"
}

#
# Entry point
#

assert_root
main
