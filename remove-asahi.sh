#!/bin/bash
# License: MIT
# Asahi Linux Partition Deletion Script for macOS
# Warning: This script will delete partitions. Ensure you have backups!

# Constants
readonly BANNER="===========================    REMOVE ASAHI LINUX   =============================="
readonly FILLER="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
readonly DVLINE="______________________________________________________________________________"
readonly TARGET_DISK="disk0"

# Check if running as root
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root or with sudo"
        exit 1
    fi
}

# Get macOS system volume
get_macos_volume() {
    local volume
    volume=$(diskutil info "$(df / | tail -1 | cut -d' ' -f 1)" | awk '/APFS Physical Store:/ {print $4}' 2>/dev/null)
    if [[ -z "$volume" ]]; then
        echo "Error: Could not determine macOS system volume"
        exit 1
    fi
    echo "$volume"
}

# Resize macOS partition
grow_macos_system() {
    local macos_volume="$1"
    echo "$DVLINE"
    echo "WARNING: System may temporarily freeze during resize operation"
    read -p "Resize macOS System [$macos_volume] to reclaim space? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        return 1
    fi
    
    echo "Resizing [$macos_volume]..."
    if ! diskutil apfs resizeContainer "$macos_volume" 0 2>/dev/null; then
        echo "Error: Failed to resize [$macos_volume]"
        return 1
    fi
    echo "[$macos_volume] resized successfully"
}

# List disk partitions
list_partitions() {
    echo "Current [$TARGET_DISK] layout:"
    echo "$DVLINE"
    if ! diskutil list "$TARGET_DISK" 2>/dev/null; then
        echo "Error: Failed to list partitions on $TARGET_DISK"
        exit 1
    fi
}

# Identify Asahi-related partitions
identify_asahi_partitions() {
    diskutil list "$TARGET_DISK" | awk '
        $2 ~ /Linux/ {print $6}
        $2 ~ /EFI/ || $5 ~ /ASAHI/ {print $8}
    ' 2>/dev/null
}

# Check if partition can be safely deleted
can_delete_partition() {
    local part="$1"
    local macos_volume="$2"
    local part_info
    part_info=$(diskutil info "$part" 2>/dev/null) || return 1
    
    local part_type
    part_type=$(echo "$part_info" | awk '/Partition Type:/ {print $3}')
    
    if [[ "$part" == "$macos_volume" ]]; then
        echo "Skipping macOS System partition: [$part]"
        return 1
    elif [[ "$part_type" == "Apple_APFS_Recovery" ]]; then
        echo "Skipping Apple_APFS_Recovery partition: [$part]"
        return 1
    elif [[ "$part_type" == "Apple_APFS_ISC" ]]; then
        echo "Skipping Apple_APFS_ISC partition: [$part]"
        return 1
    fi
    return 0
}

# Delete single partition with confirmation
delete_partition() {
    local part="$1"
    local macos_volume="$2"
    
    if can_delete_partition "$part" "$macos_volume"; then
        read -p "Delete [$part]? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Deleting [$part]..."
            if ! diskutil eraseVolume free free "$part" 2>/dev/null; then
                echo "Error: Failed to delete [$part]"
                return 1
            fi
            echo "[$part] deleted successfully"
        else
            echo "Deletion of [$part] cancelled"
        fi
    fi
}

# Delete APFS UEFI partition
delete_apfs_uefi() {
    local part
    part=$(diskutil list "$TARGET_DISK" | awk '$2 == "Apple_APFS" && $5 == "2.5" {print $7}' 2>/dev/null)
    
    if [[ -z "$part" ]]; then
        echo "No Asahi APFS UEFI partition found"
        return 1
    fi
    
    echo "$DVLINE"
    echo "Identified potential Asahi APFS container (2.5GB): [$part]"
    read -p "Delete [$part]? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deleting [$part]..."
        if ! diskutil apfs deleteContainer "$part" 2>/dev/null; then
            echo "Error: Failed to delete APFS container [$part]"
            return 1
        fi
        echo "[$part] deleted successfully"
    else
        echo "[$part] skipped"
    fi
}

# Automatic removal function
autoremove() {
    local macos_volume
    macos_volume=$(get_macos_volume)
    echo "Automatic removal of Asahi partitions..."
    
    delete_apfs_uefi
    local parts
    parts=$(identify_asahi_partitions)
    
    if [[ -z "$parts" ]]; then
        echo "No additional Asahi partitions found"
    else
        for part in $parts; do
            delete_partition "$part" "$macos_volume"
        done
    fi
    
    grow_macos_system "$macos_volume"
}

# Main execution
main() {
    check_sudo
    local macos_volume
    macos_volume=$(get_macos_volume)
    
    if [[ "$1" == "autoremove" ]]; then
        autoremove
        return 0
    fi
    
    clear
    echo "$DVLINE"
    echo "$FILLER"
    echo "$BANNER"
    echo "$FILLER"
    echo "$DVLINE"
    
    echo "WARNING: Ensure you have backups before proceeding!"
    list_partitions
    read -p "Continue with [$TARGET_DISK]? (y/n): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
    
    delete_apfs_uefi
    local partitions
    partitions=$(identify_asahi_partitions)
    
    if [[ -n "$partitions" ]]; then
        echo "$DVLINE"
        echo "Additional Asahi partitions found:"
        echo "$partitions"
        read -p "Delete these partitions? (y/n): " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            for part in $partitions; do
                delete_partition "$part" "$macos_volume"
            done
        fi
    fi
    
    echo "$DVLINE"
    echo "Final verification:"
    list_partitions
    grow_macos_system "$macos_volume"
    echo "$DVLINE"
    echo "Operation completed"
}

main "$@"
