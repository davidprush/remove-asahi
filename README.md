# remove-asahi

## Bash and ZSH scripts designed for macOS using `diskutil` to delete Asahi Linux partitions. No script can be full-proof for this process because the options are limitless; however, this script should work for most Asahi Linux installations.

**(⌐■‿■)╭☞** **Before running this script, ensure you have backups of all important data, as deleting partitions can lead to data loss.**

The script is meant to remove a typical installation of Asahi Linux on Apple Silicon.

For more information regarding macOS partitions and Asahi Linux, the Asahi team has a published a [partition cheat sheet](https://github.com/AsahiLinux/docs/wiki/Partitioning-cheatsheet).

The typical or default Asahi Linux installation has four partitions to remove (Use `diskutil list` to display):

1. Apple APFS (Apple UEFI Boot for Asahi) example: `disk0s3`
2. EFI EFI-Asahi example: `disk0s4`
3. Linux Filesystem (Asahi boot Partition) example: `disk0s5`
4. Linux Filesystem (Asahi root Partition) example: `disk0s6`

**ಠ_ಠ╭☞** Regarding the above example, `disk0s7` would be the `Apple APFS Recovery` (System Image to Resotore macOS).

**UNDER NO CIRCUMSTANCES SHOULD YOU DELETE THE `Apple APFS Recovery` PARTITION.**
*Doing so will render your system useless until you put in DFU mode and connect it to another macOS computer.*

If you simply ran the Asahi install script when you installed Asahi Linux, and you have the default installation of macOS, then your partitions should be similar to the above layout; *however, please verify this the case for your use.*

### Instructions

**Make it executable:**

`chmod +x remove-asahi.zsh`

**Run with sudo:**

`sudo ./remove-asahi.zsh`

**Notes:**

*This script uses `diskutil` to list, identify, and delete partitions. The script looks for partition labels containing "Asahi" or "Linux" and attempts to identify typical macOS system partitions (including the Recovery parition), which is not a definitive method, so double-check before confirming deletion.*

*Always verify the disk and partition identifiers to prevent accidental data loss.*
