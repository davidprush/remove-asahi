# remove-asahi.zsh

## Here's a Zsh script designed for macOS that uses `diskutil` to delete partitions specifically used by Asahi Linux

**(╭☞⌐■‿■)╭☞** **Before running this script, ensure you have backups of all important data, as deleting partitions can lead to data loss.**

The script is meant to a typical install of Asahi Linux on Apple Silicon.

There are four partitions to remove:

- Apple APFS (Apple UEFI Boot for Asahi) example: `disk0s3`
- EFI EFI-Asahi example: `disk0s4`
- Linux Filesystem (Asahi boot Partition) example: `disk0s5`
- Linux Filesystem (Asahi root Partition) example: `disk0s6`

**ಠ_ಠ** In the above example `disk0s7` is the **Apple APFS Recovery** (System Image to Resotore macOS) **UNDER NO CIRCUMSTANCES SHOULD YOU DELETE THIS PARTITION.**

If you simply ran the Asahi install script and you have the default installation of macOS then your partitions should be similar to the above layout; *however, please verify this the case for your use.*

### Instructions

**Make it executable:**

`chmod +x remove-asahi.zsh`

**Run with sudo:**

`sudo ./remove-asahi.zsh`

**Notes:**

*This script uses `diskutil` to list, identify, and delete partitions. The script looks for partition labels containing "Asahi" or "Linux", which is not a definitive method, so double-check before confirming deletion.*

*Always verify the disk and partition identifiers to prevent accidental data loss.*
