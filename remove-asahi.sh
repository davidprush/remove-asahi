#!/bin/bash
# License: MIT
# Asahi Linux Partition Deletion Script for macOS
# Warning: This script will delete partitions. Ensure you have backups!\

readonly BANNER="===========================    REMOVE ASAHI LINUX   =============================="
readonly FILLER="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
readonly DVLINE="______________________________________________________________________________"

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
       echo "!!!This script must be run as root or with sudo!!!"
       exit 1
    fi
}

grow_macos_system(){
    local macos_volume=$(diskutil info $(df / | tail -1 | cut -d' ' -f 1) | awk '/APFS Physical Store:/ {print $4}')
    echo $DVLINE
    echo -n "Do you want to resize macOS System [ $macos_volume ] to reclaim free space? (y/n):"
    read confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "  Operation cancelled."
        exit 0
    fi
    echo "  Resizing [ $macos_volume ]"
    diskutil apfs resizeContainer $macos_volume 0
    echo "  [ $macos_volume ] resized"
}

list_partitions() {
    echo "Current [ disk0 ] layout:"
    echo $DVLINE
    diskutil list disk0
}

identify_asahi_partitions() {
    diskutil list disk0 | awk '{
        if ($2 ~ /Linux/) {
            print $6
        }
        if ($2 ~ /EFI/ || $5 ~ /ASAHI/) {
            print $8 
        }
    }'
}

can_delete_partition() {
    local part=$1
    local macos_volume=$(diskutil info $(df / | tail -1 | cut -d' ' -f 1) | awk '/APFS Physical Store:/ {print $4}')
    local part_type=$(diskutil info $part | awk '/Partition Type:/ {print $3}')
    echo $DVLINE
    if [ "$part" == "$macos_volume" ]; then
        echo "  Skipping macOS System partition: [ $part ]"
        return 1  # False, do not delete macOS System partition
    fi
    
    if [ "$part_type" == "Apple_APFS_Recovery" ]; then
        echo "  Skipping Apple_APFS_Recovery partition: [ $part ]"
        return 1  # False, do not delete Apple_APFS_Recovery partition
    fi

    if [ "$part_type" == "Apple_APFS_ISC" ]; then
        echo "  Skipping Apple_APFS_ISC partition: [ $part ]"
        return 1  # False, do not delete Apple_APFS_ISC partition
    fi
    return 0  # True, can delete
}

delete_partition() {
    local partitions=$1
    echo $DVLINE
    for part in $partitions; do
        if can_delete_partition $part; then
            echo -n "Are you sure you want to delete [ $part ]? (y/n):"
            read confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                echo "   Canceled [ $part ] deletion."
            else    
                echo "  Deleting partition [ $part ]..."
                diskutil eraseVolume free free $part
            fi
        else
            echo "  Skipping deletion of this partition."
        fi
    done
}

delete_apfs_uefi() {
    local disk=$1
    local part=$(diskutil list $disk | awk '$2 == "Apple_APFS" && $5 == "2.5" {print $7}')
    if can_delete_partition $part; then
        echo $DVLINE
        echo "WARNING: This script assumes the Asahi container by type and size."
        echo "The first partition to identify for deletion:"
        echo
        echo "Asahi Apple APFS Container Disk (2.5GB)"
        echo
        echo "[ $part ] looks like the Asahi Apple APFS container (2.5GB)"
        echo
        echo -n "Are you sure you want to delete [ $part ]? (y/n): "
        read confirm
        echo
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo "  [ $part ] skipped"
        else
            echo "  Deleting the APFS UEFI partition: [ $part ]..."
            #diskutil apfs deleteContainer $part
            echo "  [ $part ] deleted"
        fi
    else
        echo "  Skipping deletion of protected partition: [ $part ]"
    fi
}

autoremove() {
    local parts=$(diskutil list $disk | awk '$2 == "Apple_APFS" && $5 == "2.5" {print $7}')
    local macos_volume=$(diskutil info $(df / | tail -1 | cut -d' ' -f 1) | awk '/APFS Physical Store:/ {print $4}')    
    echo "RUNNING: autoremove, looking for and removing all Asahi partitions."
    if can_delete_partition $parts; then
        #diskutil apfs deleteContainer $part
        echo "  Removed [ $parts ]"
    else
        echo "  No APFS Asahi Linux partition found."
    fi
    parts=$(identify_asahi_partitions)
    if [ -z "$parts" ]; then
        echo "  No other Asahi < linux filesystem > partitions found."
        exit 0
    else
        for part in $parts; do
            if can_delete_partition $part; then
                diskutil eraseVolume free free $part
                echo "  Removed  [ $part ]"
            else
                echo "  Skipping [ $part ]..."
            fi
        done
    fi
    diskutil apfs resizeContainer $macos_volume 0
    echo "  [ $macos_volume ] resized"
}

main() {
    check_sudo
    if [ -z "$1" ]; then
        clear
        echo $DVLINE
        echo $FILLER
        echo $BANNER
        echo $FILLER
        echo $DVLINE
        list_partitions
        echo $DVLINE
        echo "WARNING: This script is designed for default Asahi installations."
        echo "Only partitions on [ disk0 ] will be deleted."
        echo
        echo -n "Do you want to continue with [ disk0 ]? (y/n):"
        read confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            exit 0
        fi
        delete_apfs_uefi $disk
        partitions=$(identify_asahi_partitions)
        if [ -z "$partitions" ]; then
            echo "  No other Asahi Linux partitions found."
            exit 0
        else
            echo $DVLINE
            echo "Other Asahi Linux partitions to delete:"
            echo
            echo $partitions
            echo
            echo -n "Are you sure you want to delete these partitions? (y/n): "
            read confirm
            echo
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                echo "  Operation cancelled."
                exit 0
            fi

            for part in $partitions; do
                delete_partition $part
            done
        fi
        echo $DIVLINE
        echo $FILLER
        echo "               << Asahi partitions removed. Please verify. >>"
        echo $FILLER
        echo $DIVLINE
        list_partitions
        echo $DIVLINE
        grow_macos_system
        echo $DIVLINE
        list_partitions
        echo $DIVLINE
        echo $DIVLINE
    else
        if [ "$1" == "autoremove" ]; then
            autoremove
            exit 0
        else
            echo "INVALID COMMAND: Use [autoremove] to automatically remove Asahi and resize macOS System."
            echo "                 or you can run it without a command for a guided removal of Asahi."
            exit 1
        fi
    fi
}

main $1
