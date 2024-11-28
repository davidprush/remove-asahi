#!/bin/zsh

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

# Function to delete a partition
delete_partition() {
    local disk=$1
    local partition=$2
    echo "Deleting partition $disk$partition..."
    diskutil eraseVolume free none $disk$partition
}

# New function to find and delete the APFS UEFI partition (approx. 2.5GB)
delete_apfs_uefi() {
    local disk=$1
    local apfs_part=$(diskutil list $disk | awk '$3 == "Apple_APFS" && $4 > "2G" && $4 < "3G" {print $7}')
    if [ -n "$apfs_part" ]; then
        echo "Deleting the APFS UEFI partition: $apfs_part"
        diskutil apfs deleteContainer $apfs_part
    else
        echo "No APFS UEFI partition (2.5GB) found."
    fi
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

        # Delete identified partitions
        for part in $(echo $partitions | cut -d' ' -f2); do
            delete_partition $disk $part
        done
    fi

    echo "Partitions have been deleted. Please verify with diskutil list."
}

main