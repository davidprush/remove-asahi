# remove-asahi

## Bash script designed for macOS using `diskutil` to delete Asahi Linux partitions. No script can be full-proof for this process because the options are limitless; however, this script should work for most Asahi Linux installations.

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

`chmod +x remove-asahi.sh`

**Run with sudo:**

`sudo ./remove-asahi.sh`

**Notes:**

*This script uses `diskutil` to list, identify, and delete partitions. The script looks for partition labels containing "Asahi" or "Linux" and attempts to identify typical macOS system partitions (including the Recovery parition), which is not a definitive method, so double-check before confirming deletion.*

*Always verify the disk and partition identifiers to prevent accidental data loss.*

*If you plan on reinstalling Asahi Linux with the available free space after deleting the old installation's partitions then type `n` when asked to resize the macOS System by reclaiming free space.*

**Example of the script running:**
```
______________________________________________________________________________
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
=========================== REMOVE ASAHI LINUX ==============================
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
______________________________________________________________________________
Current [ disk0 ] layout:
______________________________________________________________________________
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk4         739.0 GB   disk0s2
   3:                 Apple_APFS Container disk3         2.5 GB     disk0s3
   4:                        EFI EFI - ASAHI             524.3 MB   disk0s4
   5:           Linux Filesystem                         1.1 GB     disk0s5
   6:           Linux Filesystem                         251.6 GB   disk0s6
   7:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s7
______________________________________________________________________________
WARNING: This script is designed for default Asahi installations.
Only partitions on [ disk0 ] will be deleted.

Do you want to continue with [ disk0 ]? (y/n):y
______________________________________________________________________________
______________________________________________________________________________
WARNING: This script assumes the Asahi container by type and size.
The first partition to identify for deletion:

Asahi Apple APFS Container Disk (2.5GB)

[ disk0s3 ] looks like the Asahi Apple APFS container (2.5GB)

Are you sure you want to delete [ disk0s3 ]? (y/n): y

  Deleting the APFS UEFI partition: [ disk0s3 ]...
Started APFS operation on disk3
Deleting APFS Container with all of its APFS Volumes
Unmounting Volumes
Unmounting Volume "Asahi - Data" on disk3s1
Unmounting Volume "Asahi" on disk3s2
Unmounting Volume "Preboot" on disk3s3
Unmounting Volume "Recovery" on disk3s4
Deleting Volumes
Deleting Container
Wiping former APFS disks
Switching content types
1 new disk created or changed due to APFS operation
Disk from APFS operation: disk0s3
Finished APFS operation on disk3
Removing disk0s3 from partition map
  [ disk0s3 ] deleted
______________________________________________________________________________
Other Asahi Linux partitions to delete:

disk0s4 disk0s5 disk0s6

Are you sure you want to delete these partitions? (y/n): y

______________________________________________________________________________
______________________________________________________________________________
Are you sure you want to delete [ disk0s4 ]? (y/n):y
  Deleting partition [ disk0s4 ]...
Started erase on disk0s4 (EFI - ASAHI)
Unmounting disk
Finished erase on disk0
______________________________________________________________________________
______________________________________________________________________________
Are you sure you want to delete [ disk0s5 ]? (y/n):y
  Deleting partition [ disk0s5 ]...
Started erase on disk0s5
Unmounting disk
Finished erase on disk0
______________________________________________________________________________
______________________________________________________________________________
Are you sure you want to delete [ disk0s6 ]? (y/n):y
  Deleting partition [ disk0s6 ]...
Started erase on disk0s6
Unmounting disk
Finished erase on disk0

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               << Asahi partitions removed. Please verify. >>
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Current [ disk0 ] layout:
______________________________________________________________________________
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk4         739.0 GB   disk0s2
                    (free space)                         255.7 GB   -
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s7

______________________________________________________________________________
Do you want to resize macOS System [ disk0s2 ] to reclaim free space? (y/n):y
  Resizing [ disk0s2 ]
Started APFS operation
Aligning grow delta to 255,662,587,904 bytes and targeting a new container size of 994,662,584,320 bytes
Determined the maximum size for the APFS Container to be 994,662,584,320 bytes
Resizing APFS Container designated by APFS Container Reference disk4
The specific APFS Physical Store being resized is disk0s2
Verifying storage system
Using live mode
Performing fsck_apfs -n -x -l /dev/disk0s2
Checking the container superblock
Checking the checkpoint with transaction ID 8371482
Checking the space manager
Checking the space manager free queue trees
Checking the object map
Checking the encryption key structures
Checking volume /dev/rdisk4s1
Checking the APFS volume superblock
The volume Macintosh HD - Data was formatted by newfs_apfs (2142.140.9) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking the document ID tree
Checking the fsroot tree
warning: inode (id 1654800): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 1658682): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 13038067): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 13300877): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 46105603): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 46106152): Resource Fork xattr is missing or empty for compressed file
warning: inode (id 46106285): Resource Fork xattr is missing or empty for compressed file
Checking the extent ref tree
Checking the file key rolling tree
Verifying volume object map space
The volume /dev/rdisk4s1 with UUID **************************** was found to be corrupt and needs to be repaired
Checking volume /dev/rdisk4s2
Checking the APFS volume superblock
The volume Update was formatted by com.apple.MobileSof (2142.81.1) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking the fsroot tree
Checking the extent ref tree
Verifying volume object map space
The volume /dev/rdisk4s2 with UUID *********************************** appears to be OK
Checking volume /dev/rdisk4s3
Checking the APFS volume superblock
The volume Macintosh HD was formatted by com.apple.MobileSof (2142.81.1) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking snapshot 1 of 1 (com.apple.os.update-************************************************, transaction ID 7826306)
Checking the fsroot tree
Checking the file extent tree
Checking the extent ref tree
Verifying volume object map space
The volume /dev/rdisk4s3 with UUID *********************************** appears to be OK
Checking volume /dev/rdisk4s4
Checking the APFS volume superblock
The volume Preboot was formatted by com.apple.MobileSof (2142.81.1) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking the fsroot tree
Checking the extent ref tree
Verifying volume object map space
The volume /dev/rdisk4s4 with UUID ***************************************** appears to be OK
Checking volume /dev/rdisk4s5
Checking the APFS volume superblock
The volume Recovery was formatted by com.apple.MobileSof (2142.81.1) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking the fsroot tree
Checking the extent ref tree
Verifying volume object map space
The volume /dev/rdisk4s5 with UUID ********************************************* appears to be OK
Checking volume /dev/rdisk4s6
Checking the APFS volume superblock
The volume VM was formatted by com.apple.MobileSof (2142.81.1) and last modified by apfs_kext (2313.41.1)
Checking the object map
Checking the snapshot metadata tree
Checking the snapshot metadata
Checking the fsroot tree
Checking the extent ref tree
Verifying volume object map space
The volume /dev/rdisk4s6 with UUID ******************************************* appears to be OK
Verifying allocated space
Performing deferred repairs
warning: need to clear bsd flags (0x20) in inode (object-id 1654800)
Skipped 7/7 repairs of this type in total
warning: found orphan/invalid xattr (id 1654800, name com.apple.decmpfs)
Skipped 7/7 repairs of this type in total
The container /dev/disk0s2 appears to be OK
Storage system check exit code is 0
Growing APFS Physical Store disk0s2 from 738,999,996,416 to 994,662,584,320 bytes
Modifying partition map
Growing APFS data structures
Finished APFS operation
  [ disk0s2 ] resized

Current [ disk0 ] layout:
______________________________________________________________________________
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk4         994.7 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s7
```
