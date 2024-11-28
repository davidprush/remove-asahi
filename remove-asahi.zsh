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

# Function to check if partition should be deleted
# Prevents deletion of macOS, Apple_APFS_ISC, and Apple_Boot partitions
can_delete_partition() {
    local partition=$1
    local disk=$(echo $partition | sed 's/[s0-9]*$//')
    local vol_names=$(diskutil list $disk | awk '$3 == "Apple_APFS" {print $7}')
    local macos_volume=$(diskutil info $vol_names | awk '/Volume Name:/ && /Macintosh HD/ {print $3}')

    if [ -n "$macos_volume" ] && diskutil info $partition | grep -q "$macos_volume"; then
        echo "Skipping macOS partition: $partition"
        return 1  # False, do not delete macOS partition
    fi

    # Check for macOS protected partitions
    if diskutil info $partition | grep -q "Apple_APFS_ISC" || diskutil info $partition | grep -q "Apple_APFS_Recovery"; then
        echo "Skipping deletion of protected partition: $partition"
        return 1  # False, do not delete macOS protected partitions
    fi
    
    return 0  # True, can delete
}

# Function to delete a partition if it's safe to do so
delete_partition() {
    local disk=$1
    local partition=$2
    if can_delete_partition $disk$partition; then
        echo "Deleting partition $disk$partition..."
        diskutil eraseVolume free none $disk$partition
    else
        echo "Skipping deletion of this partition."
    fi
}

# New function to find and delete the APFS UEFI partition (approx. 2.5GB), 
# avoiding protected partitions including macOS
delete_apfs_uefi() {
    local disk=$1
    local apfs_parts=$(diskutil list $disk | awk '$3 == "Apple_APFS" && $4 > "2G" && $4 < "3G" {print $7}')
    for part in ${(f)apfs_parts}; do
        if can_delete_partition $part; then
            echo "Deleting the APFS UEFI partition: $part"
            diskutil apfs deleteContainer $part
        else
            echo "Skipping deletion of protected partition: $part"
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

        # Delete identified partitions, skipping protected ones
        for part in $(echo $partitions | cut -d' ' -f2); do
            delete_partition $disk $part
        done
    fi

    echo "Asahi partitions removed. Please verify with diskutil list."
}

main