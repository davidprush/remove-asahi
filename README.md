# remove-asahi.zsh

Here's a Zsh script designed for macOS that uses diskutil to delete partitions specifically used by Asahi Linux. Before running this script, ensure you have backups of all important data, as deleting partitions can lead to data loss.

Instructions:
Save this script with a name like delete_asahi_partitions.zsh.
Make it executable: chmod +x delete_asahi_partitions.zsh
Run with sudo: sudo ./delete_asahi_partitions.zsh

Notes:
This script uses diskutil to list, identify, and delete partitions. The script looks for partition labels containing "Asahi" or "Linux", which is not a definitive method, so double-check before confirming deletion.
Always verify the disk and partition identifiers to prevent accidental data loss.
