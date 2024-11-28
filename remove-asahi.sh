#!/bin/bash

# Asahi Linux Partition Deletion Script for macOS
# Warning: This script will delete partitions. Ensure you have backups!

# Function to check if the user is running with sudo privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root or with sudo."
       exit 1
    fi
}

# Function to list disk identifiers
list_disks() {
    echo "Available disk identifiers:"
    diskutil list
}

# Function to identify Asahi Linux partitions
# Asahi typically uses partitions labeled with something like "Asahi" or "Linux"
identify_asahi_partitions() {
    local disk=$1
    echo "Identifying Asahi Linux partitions on $disk..."
    diskutil list $disk | awk '{
        if ($3 ~ /Asahi/ || $3 ~ /Linux/) {
            print $3 " - " $4
        }
    }'
}

# Function to delete a partition while ensuring not to delete Recovery partition
delete_partition() {
    local disk=$1
    local partition=$2
    # Check if this is not the Recovery partition
    if diskutil info $disk$partition | grep -q "Apple_Boot"; then
        echo "Skipping deletion of Recovery partition: $disk$partition"
    else
        echo "Deleting partition $disk$partition..."
        diskutil eraseVolume free none $disk$partition
    fi
}

# New function to find and delete the APFS UEFI partition (approx. 2.5GB), 
# avoiding the Recovery partition
delete_apfs_uefi() {
    local disk=$1
    local apfs_parts=$(diskutil list $disk | awk '$3 == "Apple_APFS" && $4 > "2G" && $4 < "3G" {print $7}')
    for part in $apfs_parts; do
        if ! diskutil info $part | grep -q "Apple_Boot"; then
            echo "Deleting the APFS UEFI partition: $part"
            diskutil apfs deleteContainer $part
        else
            echo "Skipping deletion of Recovery partition: $part"
        fi
    done
}

# Main script execution
main() {
    check_sudo

    list_disks

    echo -n "Enter the disk identifier to target (e.g., disk0): "
    read disk

    # First, handle the APFS UEFI partition
    delete_apfs_uefi $disk

    # Identify and delete other Asahi Linux partitions
    partitions=$(identify_asahi_partitions $disk)
    if [ -z "$partitions" ]; then
        echo "No other Asahi Linux partitions found."
    else
        echo -e "\nOther Asahi Linux partitions to delete:\n$partitions"

        echo -n "Are you sure you want to delete these partitions? (y/n): "
        read confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            exit 0
        fi

        # Delete identified partitions, skipping Recovery
        while IFS=' ' read -r label part; do
            delete_partition $disk $part
        done <<< "$partitions"
    fi

    echo "Partitions have been processed. Please verify with diskutil list."
}

main